resource "aws_cloudwatch_log_group" "cloud_inventory_lambda" {
  name = "/aws/lambda/cloud-inventory-api"
}

resource "aws_cloudwatch_log_group" "cloud_inventory_authorizer_lambda" {
  name = "/aws/lambda/cloud-inventory-authorizer"
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name = "/aws/api-gateway/cloud-inventory"
}