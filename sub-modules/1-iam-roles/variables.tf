# sub-modules/iam/variables.tf
variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "dynamodb_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
}

variable "collection_arn" {
  description = "OS Collection ARN"
  type        = string
}


variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

# variable "bedrock_agent_arn" {
#   description = "ARN of the Bedrock agent"
#   type        = string
# }
