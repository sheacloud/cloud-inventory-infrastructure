resource "aws_ecs_task_definition" "cloud_inventory_fetcher" {
  family                   = "cloud-inventory-fetcher"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  container_definitions = jsonencode([
    {
      name  = "fetcher"
      image = "${aws_ecr_repository.cloud_inventory_fetcher.repository_url}:latest"
      environment = [
        {
          name  = "CLOUD_INVENTORY_S3_BUCKET"
          value = var.cloud_inventory_s3_bucket
        },
        {
          name  = "CLOUD_INVENTORY_AWS_ACCOUNT_IDS"
          value = var.cloud_inventory_aws_account_ids
        },
        {
          name  = "CLOUD_INVENTORY_AWS_REGIONS"
          value = "us-east-1,us-west-2"
        },
        {
          name  = "CLOUD_INVENTORY_AWS_ASSUME_ROLE_NAME"
          value = var.assume_role_name
        },
        {
          name  = "CLOUD_INVENTORY_AWS_USE_LOCAL_CREDENTIALS"
          value = "false"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.inventory_fetcher.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "fetcher"
        }
      }
    }
  ])

  cpu                = var.fetcher_cpu_units
  memory             = var.fetcher_memory_units
  task_role_arn      = aws_iam_role.cloud_inventory_fetcher_task_role.arn
  execution_role_arn = aws_iam_role.cloud_inventory_fetcher_task_execution_role.arn
}