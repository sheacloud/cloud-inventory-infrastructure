resource "aws_dynamodb_table" "cloud_inventory_api_keys" {
  name         = "cloud-inventory-api-keys"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "api_key_hash"

  attribute {
    name = "api_key_hash"
    type = "B"
  }
}