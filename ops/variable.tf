variable "env" {
  description = "The environment variables to pass to the lambda, if running locally it will read from .env"
  sensitive = true
  default = {
    SOME_KEY = "SOME_VALUE"
  }
}