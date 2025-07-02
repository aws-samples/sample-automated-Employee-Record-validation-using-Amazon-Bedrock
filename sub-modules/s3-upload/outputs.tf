# sub-modules/s3_upload/outputs.tf
output "object_key" {
  description = "The key of the uploaded object"
  value       = aws_s3_object.validation_rules.key
}

output "object_version_id" {
  description = "Version ID of the uploaded object"
  value       = aws_s3_object.validation_rules.version_id
}

output "object_etag" {
  description = "ETag of the uploaded object"
  value       = aws_s3_object.validation_rules.etag
}
