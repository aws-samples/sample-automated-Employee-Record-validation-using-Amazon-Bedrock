# sub-modules/knowledge_base/variables.tf
variable "name" {
  description = "Name of the knowledge base"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  type        = string
}

# variable "kb_role_arn" {
#   description = "ARN of the OpenSearch Serverless collection"
#   type        = string
# }

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket containing validation rules"
  type        = string
}

# variable "bedrock_role_arn" {
#   description = "ARN of the Bedrock role"
#   type        = string
# }

variable "kb_role_arn" {
  description = "ARN of the Bedrock role"
  type        = string
}




