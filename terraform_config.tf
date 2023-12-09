terraform {
  
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.28.0"
    }
  }
  
  backend "s3" {
    bucket = "remotestate-tf"
    key = "roboshop-state"
    region = "us-east-1"
  }

}