provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "tf-backend-state-2022-06-05" # REPLACE YOUR S3 BUCKET
    key    = "aws-exercise/aws.tfstate"
    region = "us-west-2"
  }
}