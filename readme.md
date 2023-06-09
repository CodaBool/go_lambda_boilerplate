> Boilerplate Go for Quotai 🍴 fork me

# Usage

### Requirements
- [just](https://github.com/casey/just)
- Docker
- aws credentials configured with AWS CLI
- Terraform

### Commands
> assumes you have a Docker daemon and have your AWS CLI configured
- `just build` builds the docker container
- `just run` starts a simulated lambda on port 9000
- `just test` sends a request to the simulated lambda