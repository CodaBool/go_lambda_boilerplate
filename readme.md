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

### Deployment
```
cd ops
terraform init
terraform apply (type yes if you agree to make the resources)
```

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