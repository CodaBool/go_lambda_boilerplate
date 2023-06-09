# in Terraform you can provide a value with the var flag
# this can be used in the pipeline with github actions secrets
# then added to the terraform apply like below
# e.g. terraform apply -var="env={KEY=VALUE}"

# Terraform will first read key value pairs from an .env file in the dockerfile folder
variable "env" {
  description = "The environment variables to pass to the lambda, if running locally it will read from .env"
  sensitive = true
  default = {
    SOME_KEY = "SOME_VALUE"
  }
}