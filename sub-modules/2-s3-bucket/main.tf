# sub-modules/s3/main.tf

resource "random_id" "timestamp" {
  byte_length = 4
}

resource "aws_s3_bucket" "kb_bucket" {
  bucket = "${var.bucket_name}-${random_id.timestamp.hex}"

  tags = {
    Name        = var.bucket_name
    Project     = var.project_name
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "kb_bucket_encryption" {
  bucket = aws_s3_bucket.kb_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "kb_bucket_access" {
  bucket = aws_s3_bucket.kb_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Disable ACLs
resource "aws_s3_bucket_ownership_controls" "kb_bucket_ownership" {
  bucket = aws_s3_bucket.kb_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "kb_bucket_versioning" {
  bucket = aws_s3_bucket.kb_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable access logging
resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.bucket_name}-logs"

  tags = {
    Name        = "${var.bucket_name}-logs"
    Project     = var.project_name
  }
}

# Enforce HTTPS-only access
resource "aws_s3_bucket_policy" "kb_bucket_https_policy" {
  bucket = aws_s3_bucket.kb_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "EnforceHTTPSOnly"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.kb_bucket.arn,
          "${aws_s3_bucket.kb_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.kb_bucket_access]
}

# Lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "kb_bucket_lifecycle" {
  bucket = aws_s3_bucket.kb_bucket.id

  rule {
    id     = "knowledge_base_lifecycle"
    status = "Enabled"

    # Transition current version objects
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    # Handle non-current versions (since versioning is enabled)
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    # Delete non-current versions after 2 years
    noncurrent_version_expiration {
      noncurrent_days = 730
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}