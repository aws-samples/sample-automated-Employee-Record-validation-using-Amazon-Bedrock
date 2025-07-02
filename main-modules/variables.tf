
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "checkUpdateBlog"
}

variable "bucket_name" {
  description = "Bucket name"
  type        = string
  default     = "bedrock-agent-kb"
}

variable "kb_instructions_for_agent" {
  description = "Description of the agent"
  type        = string
  default     = <<-EOT
For empty attributes, use knowledge base to inform users about allowed values and pattern.
EOT
}

variable "enable_bedrock_logging" {
  description = "Enable Bedrock model invocation logging to S3"
  type        = bool
  default     = true
}

# variable "function_name" {
#   description = "Function name"
#   type        = string
# }

