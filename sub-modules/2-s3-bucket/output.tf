# sub-modules/s3/outputs.tf
output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.kb_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.kb_bucket.arn
}