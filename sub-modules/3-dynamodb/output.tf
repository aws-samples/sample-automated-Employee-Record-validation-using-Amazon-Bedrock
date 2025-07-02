# sub-modules/dynamodb/outputs.tf
output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.main.arn
}

output "table_id" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.main.id
}

output "table_stream_arn" {
  description = "ARN of the DynamoDB table stream"
  value       = aws_dynamodb_table.main.stream_arn
}
