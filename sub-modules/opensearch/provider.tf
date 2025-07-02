terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.69"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "= 2.3.0"
    }
  }
}

provider "opensearch" {
  url         = aws_opensearchserverless_collection.main.collection_endpoint
  healthcheck = false
}