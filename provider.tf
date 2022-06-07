provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "tf-backend-state-2022-06-05"
    key    = "aws-exercise/aws.tfstate"
    region = "us-west-2"
  }
}