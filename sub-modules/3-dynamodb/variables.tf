# sub-modules/dynamodb/variables.tf
variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "sample_data" {
  description = "List of sample items to add to the table"
  type = list(object({
    Name    = string
    Age     = string
    ID   = string
    Status  = string
    Surname = string
  }))
  default = []
}
