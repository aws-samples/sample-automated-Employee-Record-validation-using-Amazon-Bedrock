#This has IAM role for Lambda and IAM role for KnowledgeBase

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.function_name}-role"
    Project     = var.project_name
  }
}

# CloudWatch Logs policy
resource "aws_iam_role_policy" "lambda_logging" {
  name = "lambda-logging"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]   #create log group to remove wildcards
      }
    ]
  })
}

# DynamoDB policy
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "lambda-dynamodb"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = [var.dynamodb_arn]
      }
    ]
  })
}

# IAM Role for Knowledge Base
resource "aws_iam_role" "kb_role" {
  name = "AmazonBedrockExecutionRoleForKnowledgeBase-kb-${var.project_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name        = "kb-role"
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy" "kb_access" {
  name = "KBAccessPolicy"
  role = aws_iam_role.kb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:ListCustomModels",
          "bedrock:InvokeModel",
        ]
        Resource = "arn:aws:bedrock:${data.aws_region.this.name}::foundation-model/amazon.titan-embed-text-v2:0"
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "S3AccessForKnowledgeBase"
  role = aws_iam_role.kb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucket",
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

# # Resource-based policy for Bedrock
# resource "aws_lambda_permission" "bedrock_invoke" {
#   statement_id  = "AllowBedrockInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = var.function_name
#   principal     = "bedrock.amazonaws.com"
#   source_arn    = var.bedrock_agent_arn
# }


resource "aws_iam_role_policy" "kb_Access" {
  name = "OpensearchServerlessAccessPolicy"
  role = aws_iam_role.kb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aoss:APIAccessAll"
        ]
        Resource = "${var.collection_arn}"
      }
    ]
  })
}