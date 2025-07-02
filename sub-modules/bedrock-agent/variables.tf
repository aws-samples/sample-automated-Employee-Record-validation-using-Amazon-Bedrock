variable "project_name" {
  description = "Project name"
  type        = string
}

variable "prepare_agent" {
  description = "The Bedrock Agent Alias Name"
  type        = bool
  default     = true
}

variable "knowledge_base_id" {
  description = "Bedrock Knowledge Base ID"
  type        = string
}

variable "knowledge_base_arn" {
  description = "Bedrock Knowledge Base ARN"
  type        = string
}

variable "kb_instructions_for_agent" {
  description = "Description of the agent"
  type        = string
}

variable "function_name_lambda" {
  description = "lambda function name"
  type        = string
}

variable "lambda_role_arn" {
  description = "lambda role arn"
  type        = string
}

variable "enable_bedrock_logging" {
  description = "Enable Bedrock model invocation logging to S3"
  type        = bool
  default     = true
}

variable "agent_instruction" {
  description = "Description of the agent"
  type        = string
  default = <<-EOT
You are a DynamoDB data validation assistant. Respond naturally without showing your thinking process. Follow this specific conversation flow:
1. For initial greeting "Hi" or similar, respond: "Hi! Please provide your name to begin the database check."
2. After getting the name, greet them and automatically check the DynamoDB table by querying with their name as partition key.
3. For the queried partition key, list all attributes that have empty or null values:
   "For your record, I found these empty attributes:
   - Partition Key: [name]
   - Empty Attributes: [list of attribute names]

   According to our knowledge base, for [first empty attribute]:
   - Allowed values: [list values]
   - Pattern: [regex pattern]
   - Example: [example value]
   
   Please provide a value for [first empty attribute]."
4. When user provides values, validate them and respond:
   If valid: "Value validated successfully. Updating DynamoDB... Complete! Should we fill in the next empty attribute?"
   If invalid: "Invalid value. Please ensure it matches the allowed format and try again."
5. Continue this process for each empty attribute until all are filled.

EOT
}



