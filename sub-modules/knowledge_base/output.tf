# sub-modules/knowledge_base/outputs.tf
output "knowledge_base_arn" {
  description = "ARN of the Bedrock knowledge base"
  value       = aws_bedrockagent_knowledge_base.main_kb.arn
}

output "knowledge_base_id" {
  description = "ID of the Bedrock knowledge base"
  value       = aws_bedrockagent_knowledge_base.main_kb.id
}

