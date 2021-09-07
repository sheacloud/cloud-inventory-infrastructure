resource "aws_iam_policy" "cloud_inventory_scraper_task_policy" {
  name        = "cloud-inventory-scraper-task-policy"
  path        = "/"
  description = "Allow cloud inventory access to Cloudwatch logs and assume-role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = [
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.inventory_scraper.name}:log-stream:*",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.inventory_scraper.name}"
        ]
      },
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iam::*:role/${var.assume_role_name}"
      },
      {
          Action = "s3:PutObject"
          Effect = "Allow"
          Resource = "arn:aws:s3:::${var.inventory_bucket_name}/*"
      }
    ]
  })
}


resource "aws_iam_role" "cloud_inventory_scraper_task_role" {
  name = "cloud-inventory-scraper-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloud_inventory_scraper_task_attach" {
  role       = aws_iam_role.cloud_inventory_scraper_task_role.name
  policy_arn = aws_iam_policy.cloud_inventory_scraper_task_policy.arn
}


resource "aws_iam_role" "cloud_inventory_scraper_task_execution_role" {
  name = "cloud-inventory-scraper-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloud_inventory_scraper_task_execution_role_aws_attach" {
  role       = aws_iam_role.cloud_inventory_scraper_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}




resource "aws_iam_policy" "cloud_inventory_scraper_events_policy" {
    name        = "cloud-inventory-scraper-eventbridge-policy"
    path        = "/"
    description = "Allow eventbridge to execute cloud-inventory-scraper tasks"

    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
        Action = [
            "ecs:RunTask"
        ]
        Effect   = "Allow"
        Resource = "${replace(aws_ecs_task_definition.cloud_inventory_scraper.arn, "/:\\d+$/", ":*")}"
        },
        {
          Action = "iam:PassRole"
          Effect = "Allow"
          Resource = "*"
        }
    ]
    })
}

resource "aws_iam_role" "cloud_inventory_scraper_events_role" {
  name = "cloud-inventory-scraper-eventbridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloud_inventory_scraper_events_attach" {
  role       = aws_iam_role.cloud_inventory_scraper_events_role.name
  policy_arn = aws_iam_policy.cloud_inventory_scraper_events_policy.arn
}