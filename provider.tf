terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region     = "us-east-2"
  access_key = "AKIAQHXN4XODTVOGTXWZ"
  secret_key = "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"
}
