resource "aws_s3_object" "validation_rules" {
  bucket = var.bucket_id
  key    = "validation_rules.json"
  source = var.file_path
  
  content_type = var.content_type
  
  tags = {
    Name        = "validation_rules"
    Project     = var.project_name
  }
}
