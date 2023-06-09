> Boilerplate Go for Quotai 🍴 fork me

# Usage
### Requirements
- [just](https://github.com/casey/just)
- Docker
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)

### Commands
> assumes you have a Docker daemon and have your AWS CLI configured
- `just build` builds the docker container
- `just run` starts a simulated lambda on port 9000
- `just test` sends a request to the simulated lambda

# Deployment
```
cd ops
terraform init
terraform apply (type yes if you agree to make the resources)
```

### Automation
I like to do solutions with GitHub Actions where any git push will trigger GitHub to deploy any code changes. This is a little more involved since you will need to create a OpenID with GitHub and AWS. Which provides a token to the pipeline to authenticate it with AWS. Then a terraform apply can be ran for you (if necessary) anytime you commit, deploying the updated lambda.

# Resources
- cloudwatch, (scheduled runs)
  - schedule
    - permission
    - event rule
    - event target
  - logs
    - delete logs (number of days)
    - create logs	 
- iam assume role
  - create logs
  - 
- lambda function
- ecr
  - ecr policy to delete old images
  - push if change

# Secrets
A .env file at the root will be read by Terraform. This would be a good way to load a KEY file to validate client requests.