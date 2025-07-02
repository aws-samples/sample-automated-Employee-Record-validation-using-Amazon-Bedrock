output "bedrock_agent_arn" {
  description = "ARN of the Bedrock Agent"
  value       = module.bedrock_agent_and_action_group.bedrock_agent_arn
}

output "bedrock_logging_bucket_name" {
  description = "Name of the S3 bucket for Bedrock model invocation logging"
  value       = module.bedrock_agent_and_action_group.bedrock_logging_bucket_name
}

output "bedrock_logging_bucket_arn" {
  description = "ARN of the S3 bucket for Bedrock model invocation logging"
  value       = module.bedrock_agent_and_action_group.bedrock_logging_bucket_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.table_id
}

output "knowledge_base_id" {
  description = "ID of the Bedrock Knowledge Base"
  value       = module.knowledge_base.knowledge_base_id
}
