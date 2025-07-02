# Bedrock Knowledge Base
resource "aws_bedrockagent_knowledge_base" "main_kb" {
  name     = "${var.project_name}-${var.name}"
  role_arn = var.kb_role_arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
    }
    type = "VECTOR"
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = var.collection_arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA" 
      }
    }
  }

  tags = {
    Name        = var.name
    Project     = var.project_name
  }
}

# Create Knowledge Base Data Source
resource "aws_bedrockagent_data_source" "main_datasource" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.main_kb.id
  name             = "validation-rules-source"
  description      = "Data source for validation rules"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.s3_bucket_arn  # from s3 module
    }
  }
}



# Sync the Data Source
resource "null_resource" "sync_data_source" {
  triggers = {
    data_source_id = aws_bedrockagent_knowledge_base.main_kb.id
  }

  provisioner "local-exec" {
    command = <<EOF
    aws bedrock-agent start-ingestion-job \
    --knowledge-base-id "${aws_bedrockagent_knowledge_base.main_kb.id}" \
    --data-source-id "${aws_bedrockagent_data_source.main_datasource.data_source_id}" \
    --region ${data.aws_region.current.name}
    EOF
  }
}



