# sub-modules/opensearch/outputs.tf
output "collection_arn" {
  description = "ARN of the OpenSearch collection"
  value       = aws_opensearchserverless_collection.main.arn
}

output "collection_endpoint" {
  description = "Endpoint of the OpenSearch collection"
  value       = aws_opensearchserverless_collection.main.collection_endpoint
}


output "bedrock_role_arn" {
  value = aws_iam_role.bedrock_role.arn
}
