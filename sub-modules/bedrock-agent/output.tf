output "bedrock_agent_arn" {
  description = "ID of the Bedrock knowledge base"
  value       = aws_bedrockagent_agent.bedrock_agent.agent_arn
}

output "bedrock_logging_bucket_name" {
  description = "Name of the S3 bucket for Bedrock model invocation logging"
  value       = length(aws_s3_bucket.bedrock_logging) > 0 ? aws_s3_bucket.bedrock_logging[0].bucket : null
}

output "bedrock_logging_bucket_arn" {
  description = "ARN of the S3 bucket for Bedrock model invocation logging"
  value       = length(aws_s3_bucket.bedrock_logging) > 0 ? aws_s3_bucket.bedrock_logging[0].arn : null
}
