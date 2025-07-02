# sub-modules/opensearch/variables.tf
variable "collection_name" {
  description = "Name of the OpenSearch collection"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "knowledge_base_role_arn" {
  description = "IAM Role ARN for KB Role"
  type        = string
}

