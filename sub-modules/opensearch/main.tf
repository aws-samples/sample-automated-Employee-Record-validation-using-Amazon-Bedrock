
# Encryption Security Policy
resource "aws_opensearchserverless_security_policy" "encryption" {
  name = "encryption-policy"
  type = "encryption"
  
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${var.collection_name}"
        ]
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

# Network Security Policy
resource "aws_opensearchserverless_security_policy" "network" {
  name = "network-policy"
  type = "network"
  
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource = [
            "collection/${var.collection_name}"
          ]
        },
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${var.collection_name}"
          ]
        }
      ]
      AllowFromPublic = true
    }
  ])
}

# Data Access Policy
# Data Access Policy
resource "aws_opensearchserverless_access_policy" "access" {
  name = "access-policy"
  type = "data"
  
  policy = jsonencode([
    {
      Description = "Access policy for OpenSearch collection",
      Rules = [
        {
          ResourceType = "index",
          Resource = ["index/${var.collection_name}/*"],
          Permission = [
            "aoss:ReadDocument",
            "aoss:WriteDocument",
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex"
          ]
        },
        {
          ResourceType = "collection",
          Resource = ["collection/${var.collection_name}"],
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems"
          ]
        }
      ],
      Principal = [
        "${var.knowledge_base_role_arn}",
        data.aws_caller_identity.this.arn,
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/aws-service-role/bedrock.amazonaws.com/AWSServiceRoleForAmazonBedrock",
        "arn:aws:iam::354116860249:role/aditranj-testing"
      ]
    }
  ])
}



#IAM role for bedrock:

resource "aws_iam_role" "bedrock_role" {
  name = "AmazonBedrockExecutionRoleForKB-${var.collection_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.this.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:knowledge-base/*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "opensearch_serverless_access" {
  name = "OpensearchServerlessAccessPolicy"
  role = aws_iam_role.bedrock_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aoss:DashboardsAccessAll",
          "aoss:CreateCollection",
          "aoss:DeleteCollection",
          "aoss:UpdateCollection",
          "aoss:GetCollection",
          "aoss:CreateAccessPolicy",
          "aoss:CreateSecurityPolicy",
          "aoss:APIAccessAll"
        ]
        Resource = "arn:aws:aoss:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:collection/*"
      }
    ]
  })
}


resource "aws_iam_role_policy" "bedrock_access" {
  name = "BedrockAccessPolicy"
  role = aws_iam_role.bedrock_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:ListCustomModels",
          "bedrock:InvokeModel"
        ]
        Resource = "arn:aws:bedrock:${data.aws_region.this.name}::foundation-model/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "S3AccessForKnowledgeBase"
  role = aws_iam_role.bedrock_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:Describe*",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*"
        ]
        Resource = [
          "arn:aws:s3:::${var.collection_name}-${data.aws_caller_identity.this.account_id}",
          "arn:aws:s3:::${var.collection_name}-${data.aws_caller_identity.this.account_id}/*"
        ]
      }
    ]
  })
}


# OpenSearch Serverless Collection
resource "aws_opensearchserverless_collection" "main" {
  name = "${var.collection_name}"
  type = "VECTORSEARCH"
  description = "Collection for vector search data"
  
  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network,
    aws_opensearchserverless_access_policy.access
  ]

  tags = {
    Name        = var.collection_name
    Project     = var.project_name
  }
}

# OpenSearch Vector Index
resource "opensearch_index" "vector_index" {
  name                           = "bedrock-knowledge-base-default-index"
  number_of_shards               = "2"
  number_of_replicas             = "1"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings                       = <<-EOF
    {
      "properties": {
        "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": "1024",
          "method": {
            "name": "hnsw",
            "engine": "FAISS",
            "parameters": {
              "m": 16,
              "ef_construction": 512
            },
            "space_type": "l2"
          }
        },
        "AMAZON_BEDROCK_METADATA": {
          "type": "text",
          "index": "false"
        },
        "AMAZON_BEDROCK_TEXT_CHUNK": {
          "type": "text",
          "index": "true"
        }
      }
    }
  EOF
  lifecycle {
    ignore_changes = all
  }
  force_destroy = true
}





