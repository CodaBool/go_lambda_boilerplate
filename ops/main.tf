# put your AWS account ID here to restrict this terraform to only run on your desired account
# can get your Account ID with `aws sts get-caller-identity | jq -r .Account`
provider "aws" {
  region              = "us-east-1"
  # allowed_account_ids = ["919759177803"]
}

terraform {
  required_version = ">= 1.3.6, < 2.0.0"
  required_providers {
    aws = {
      version = ">= 5.0, < 6.0"
    }
  }
}

# variables
locals {
  name = "quotia"
  memory = 512 # Mb
  path_to_docker_file = "../src"
  tag = "latest"
  # cron expression https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
  interval = "cron(0 12 1 * ? *)" # 1st of every month, 12pm UTC (7am est)
  keep_logs_for = 60 # days
  # reads a .env file at the root. This will get passed to the lambda as env vars
  env = fileexists("../.env") ? { for tuple in regexall("(.*)=(.*)", file("../.env")) : tuple[0] => tuple[1] } : var.env
  event_input = jsonencode({
    "key": "123abc",
    "quotes_seen": [
      1,  2
    ]
  })

  # environment = {
  #   key = "YOUR_SECRET"
  # }
  # will read a .env file in the root
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function_url" "main" {
  function_name      = aws_lambda_function.main.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name_prefix         = "scheduled-${aws_lambda_function.main.function_name}"
  schedule_expression = local.interval
  description         = "Invoke the ${aws_lambda_function.main.function_name} Lambda function"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule  = aws_cloudwatch_event_rule.event_rule.id
  arn   = aws_lambda_function.main.arn
  input = local.event_input
}

resource "aws_iam_role" "lambda_assume" {
  name               = "${local.name}-lambda-assume"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "logs_create" {
  role       = aws_iam_role.lambda_assume.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "delete_old_logs" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = local.keep_logs_for
}

resource "aws_lambda_function" "main" {
  function_name    = local.name
  role             = aws_iam_role.lambda_assume.arn
  package_type     = "Image"
  memory_size      = local.memory
  timeout          = 900 # max 900
  image_uri        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${local.name}:latest"

  # TODO: There should be a way to use Terraform filemd5 function for this
  source_code_hash = split("sha256:", data.aws_ecr_image.lambda.id)[1]
  # source_code_hash = filemd5("../dist/${each.value}")
  environment {
    variables = local.env
  }
}

data "aws_ecr_image" "lambda" {
  depends_on      = [null_resource.push]
  repository_name = local.name
  image_tag       = local.tag
}

resource "aws_ecr_repository" "main" {
  name = local.name
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "remove_old_images" {
  repository = aws_ecr_repository.main.name
  # example use of keeping certain tag image
  # https://github.com/mathspace/terraform-aws-ecr-docker-image/blob/master/main.tf
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description = "Delete untagged images"
      action = { 
        type = "expire" 
      }
      selection = {
        tagStatus = "untagged"
        countType = "sinceImagePushed"
        countUnit = "days"
        countNumber = 1
      }
    }]
  })
}

# Necessary since the initial push would have relied on 
data "external" "hash" {
  program = ["./hash.sh", local.path_to_docker_file]
}

# Build and push the Docker image whenever the hash changes
resource "null_resource" "push" {
  triggers = {
    hash = data.external.hash.result["hash"]
  }
  provisioner "local-exec" {
    command     = "./push.sh ${local.path_to_docker_file} ${aws_ecr_repository.main.repository_url} ${local.tag}"
    interpreter = ["bash", "-c"]
  }
}