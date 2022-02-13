
resource "aws_apigatewayv2_api" "cloud_inventory" {
  name          = "cloud-inventory"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.cloud_inventory.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = jsonencode({ "requestId" : "$context.requestId", "ip" : "$context.identity.sourceIp", "requestTime" : "$context.requestTime", "httpMethod" : "$context.httpMethod", "routeKey" : "$context.routeKey", "path" : "$context.path", "domainName" : "$context.domainName", "status" : "$context.status", "protocol" : "$context.protocol", "responseLength" : "$context.responseLength", "user_id" : "$context.authorizer.user_id" })
  }
}

resource "aws_apigatewayv2_integration" "cloud_inventory_ingestion" {
  api_id           = aws_apigatewayv2_api.cloud_inventory.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "cloud inventory API"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.cloud_inventory_api.invoke_arn
  payload_format_version = "2.0"

  depends_on = [
    aws_lambda_permission.api_gateway,
  ]
}

resource "aws_apigatewayv2_route" "cloud_inventory" {
  api_id    = aws_apigatewayv2_api.cloud_inventory.id
  route_key = "$default"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.custom_auth.id

  target = "integrations/${aws_apigatewayv2_integration.cloud_inventory_ingestion.id}"
}

resource "aws_apigatewayv2_route" "cloud_inventory_docs" {
  api_id    = aws_apigatewayv2_api.cloud_inventory.id
  route_key = "GET /docs/{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.cloud_inventory_ingestion.id}"
}

resource "aws_apigatewayv2_domain_name" "cloud_inventory" {
  domain_name = "${local.hostname}.${var.public_domain_name}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.cloud_inventory.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "cloud_inventory" {
  api_id      = aws_apigatewayv2_api.cloud_inventory.id
  domain_name = aws_apigatewayv2_domain_name.cloud_inventory.id
  stage       = aws_apigatewayv2_stage.default.id
}

resource "aws_apigatewayv2_authorizer" "custom_auth" {
  api_id                            = aws_apigatewayv2_api.cloud_inventory.id
  authorizer_type                   = "REQUEST"
  name                              = "cloud-inventory-custom-authorizer"
  authorizer_payload_format_version = "2.0"
  authorizer_result_ttl_in_seconds  = 0
  authorizer_uri                    = aws_lambda_function.cloud_inventory_authorizer.invoke_arn
  enable_simple_responses           = true
  identity_sources                  = ["$request.header.X-API-Key"]
}