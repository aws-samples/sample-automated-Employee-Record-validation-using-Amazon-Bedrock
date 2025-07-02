module "iam" {
  source = "../sub-modules/1-iam-roles"
  function_name     = "${var.project_name}-bedrock-agent-lambda"
  project_name      = var.project_name
  dynamodb_arn      = module.dynamodb.table_arn #change name as needed
  collection_arn    = module.opensearch.collection_arn
  bucket_name       = module.bucket_for_knowledgebase_data_source.bucket_id
  # bedrock_agent_arn = module.bedrock_agent_and_action_group.bedrock_agent_arn #change name as needed
  depends_on = [
    module.dynamodb,
    module.bucket_for_knowledgebase_data_source
  ]
}

module "bucket_for_knowledgebase_data_source" {
    source              = "../sub-modules/2-s3-bucket"
    bucket_name         = "bedrock-agent-kb-${var.bucket_name}"
    project_name        = var.project_name
}

module "s3_upload" {
  source = "../sub-modules/s3-upload"
  
  bucket_id    = module.bucket_for_knowledgebase_data_source.bucket_id
  file_path    = "../resources/validation_rules.json"
  content_type = "application/json"
  project_name = var.project_name
}


# main.tf in root folder
module "dynamodb" {
  source = "../sub-modules/3-dynamodb"
  table_name    = "employee-records"
  project_name  = var.project_name
  sample_data   = [
    {
      Name    = "Test"
      Age     = ""
      ID   = "1234"
      Status  = ""
      Surname = ""
    },
    {
      Name    = "John"
      Age     = "30"
      ID   = "54321"
      Status  = "Pending"
      Surname = "Doe"
    },
    {
      Name    = "Test123"
      Age     = ""
      ID   = ""
      Status  = "Active"
      Surname = "User"
    }
  ]
}


# main.tf in root folder
module "opensearch" {
  source = "../sub-modules/opensearch"
  
  collection_name = "bedrock-collection"
  project_name    = var.project_name
  knowledge_base_role_arn = module.iam.role_arn
}


# main.tf in root folder
module "knowledge_base" {
  source = "../sub-modules/knowledge_base"
  name           = "kb-agent-kb"
  project_name   = var.project_name
  collection_arn = module.opensearch.collection_arn
  kb_role_arn    = module.iam.role_arn
  s3_bucket_arn  = module.bucket_for_knowledgebase_data_source.bucket_arn
  depends_on = [module.opensearch]
}


module "bedrock_agent_and_action_group" {
  source = "../sub-modules/bedrock-agent"
  function_name_lambda = "${var.project_name}-lambda-function"
  lambda_role_arn = module.iam.lambda_role_arn
  project_name   = var.project_name
  knowledge_base_id = module.knowledge_base.knowledge_base_id
  kb_instructions_for_agent = var.kb_instructions_for_agent
  knowledge_base_arn = module.knowledge_base.knowledge_base_arn
  enable_bedrock_logging = var.enable_bedrock_logging
}





