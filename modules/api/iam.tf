resource "aws_iam_role" "cloud_inventory_api_lambda_role" {
  name = "cloud-inventory-api-lambda-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "cloud_inventory_api_lambda_policy" {
  name        = "cloud-inventory-api-lambda-policy"
  path        = "/"
  description = "Allow lambda function to write to Kinesis"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/cloud-inventory-api:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.cloud_inventory_s3_bucket}/*",
          "arn:aws:s3:::${var.cloud_inventory_s3_bucket}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ],
        "Resource" : "*"
      },
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/cloud-inventory-*"
      },
      {
        Action = [
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/cloud-inventory-*/index/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloud_inventory_api_lambda" {
  role       = aws_iam_role.cloud_inventory_api_lambda_role.name
  policy_arn = aws_iam_policy.cloud_inventory_api_lambda_policy.arn
}






resource "aws_iam_role" "cloud_inventory_authorizer_lambda_role" {
  name = "cloud-inventory-authorizer-lambda-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "cloud_inventory_authorizer_lambda_policy" {
  name        = "cloud-inventory-authorizer-lambda-policy"
  path        = "/"
  description = "Allow lambda function to write to Kinesis"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/cloud-inventory-authorizer:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
        ],
        "Resource" : aws_dynamodb_table.cloud_inventory_api_keys.arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloud_inventory_authorizer_lambda" {
  role       = aws_iam_role.cloud_inventory_authorizer_lambda_role.name
  policy_arn = aws_iam_policy.cloud_inventory_authorizer_lambda_policy.arn
}



