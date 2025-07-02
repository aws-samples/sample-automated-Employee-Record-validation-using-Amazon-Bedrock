terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.3"
    }
  }  
  required_version = ">= 1.0" 

}



provider "aws" {
  region = "us-east-1"

}

