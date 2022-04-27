data "archive_file" "dummy" {
  type        = "zip"
  output_path = "${path.module}/dummy_lambda_payload.zip"

  source {
    content  = "foo"
    filename = "bar.txt"
  }
}

resource "aws_lambda_function" "cloud_inventory_api" {
  function_name = "cloud-inventory-api"
  role          = aws_iam_role.cloud_inventory_api_lambda_role.arn
  handler       = "cloud-inventory-api"
  filename      = data.archive_file.dummy.output_path
  memory_size   = 2048

  timeout = 30

  runtime = "go1.x"

  tracing_config {
    mode = var.enable_tracing ? "Active" : "PassThrough"
  }

  environment {
    variables = {
      "LOG_LEVEL"                     = "INFO"
      "CLOUD_INVENTORY_S3_BUCKET"     = var.cloud_inventory_s3_bucket
      "CLOUD_INVENTORY_API_URL"       = "${aws_apigatewayv2_domain_name.cloud_inventory.domain_name}"
      "GIN_MODE"                      = "release"
      "CLOUD_INVENTORY_DATABASE_TYPE" = "dynamodb"
    }
  }

  lifecycle {
    ignore_changes = [last_modified, filename, source_code_hash]
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "allow-cloud-inventory-api-apigateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloud_inventory_api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.cloud_inventory.execution_arn}/*/*"
}



resource "aws_lambda_function" "cloud_inventory_authorizer" {
  function_name = "cloud-inventory-authorizer"
  role          = aws_iam_role.cloud_inventory_authorizer_lambda_role.arn
  handler       = "cloud-inventory-authorizer"
  filename      = data.archive_file.dummy.output_path
  memory_size   = 128

  timeout = 30

  runtime = "go1.x"

  tracing_config {
    mode = var.enable_tracing ? "Active" : "PassThrough"
  }

  environment {
    variables = {
      "LOG_LEVEL"                            = "INFO"
      "CLOUD_INVENTORY_API_KEYS_TABLE"       = aws_dynamodb_table.cloud_inventory_api_keys.name
      "CLOUD_INVENTORY_COGNITO_USER_POOL_ID" = var.cognito_user_pool_id
    }
  }

  lifecycle {
    ignore_changes = [last_modified, filename, source_code_hash]
  }
}

resource "aws_lambda_permission" "api_gateway_authorizer" {
  statement_id  = "allow-cloud-inventory-authorizer-apigateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloud_inventory_authorizer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.cloud_inventory.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.custom_auth.id}"
}
