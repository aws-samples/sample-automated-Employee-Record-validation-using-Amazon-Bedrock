# sub-modules/s3_upload/variables.tf
variable "bucket_id" {
  description = "ID of the S3 bucket to upload to"
  type        = string
}

variable "file_path" {
  description = "Local path of the file to upload"
  type        = string
}

variable "content_type" {
  description = "Content type of the file"
  type        = string
  default     = "application/json"
}

variable "project_name" {
  description = "Project name"
  type        = string
}
