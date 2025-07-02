resource "aws_dynamodb_table" "main" {
  name           = "${var.project_name}-${var.table_name}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Name"
  point_in_time_recovery {
    enabled = true
  } 

  
  attribute {
    name = "Name"
    type = "S"
  }

  tags = {
    Name        = var.table_name
    Project     = var.project_name
  }
}

# Add synthetic data
resource "aws_dynamodb_table_item" "sample_items" {
  for_each = { for idx, item in var.sample_data : idx => item }

  table_name = aws_dynamodb_table.main.name
  hash_key   = "Name"

  item = jsonencode({
    Name    = { S = each.value.Name }
    Age     = { S = each.value.Age }
    ID   = { S = each.value.ID }
    Status  = { S = each.value.Status }
    Surname = { S = each.value.Surname }
  })
}
