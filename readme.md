> Boilerplate Go for Quotai 🍴 fork me

# Usage
### Requirements
- [just](https://github.com/casey/just)
- [Docker](https://docs.docker.com/engine/install/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)

### Commands
> assumes you have a Docker daemon and have your AWS CLI configured. Also be cd'd into the src folder
- `just build` builds the docker container
- `just run` starts a simulated lambda on port 9000
- `just test` sends a request to the simulated lambda

# Deployment
## Resources
- cloudWatch
  - scheduled runs
    - permission
    - event rule (lambda input)
    - event target
  - logs
    - delete logs (based on number of days old)
    - create logs	 
- role (attached to lambda)
  - permission to create logs 
  - permission to execution lambda
- lambda function
- ECR
  - ECR policy to delete old images
  - push if change

## Command
```
cd ops
terraform init
terraform apply (type yes if you agree to make the resources)
```

## Automation
I like to do solutions with GitHub Actions where any git push will trigger GitHub to deploy any code changes. This is a little more involved since you will need to create a [OpenID with GitHub and AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services). Which provides a token to the pipeline to authenticate it with AWS. Then a terraform apply can be ran for you (if necessary) anytime you commit, deploying the updated lambda.

# Secrets
A .env file at the root will be read by Terraform. This would be a good way to load a KEY file to validate client requests.

# Logs
> logs are placed in a log group named `/aws/lambda/quotia`. You can read these logs with the CLI

`aws logs tail /aws/lambda/quotia --follow --since 60m --format short`