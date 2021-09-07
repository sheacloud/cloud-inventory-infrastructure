resource "aws_ecs_task_definition" "cloud_inventory_scraper" {
  family                   = "cloud-inventory-scraper"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  container_definitions = jsonencode([
      {
          name = "scraper"
          image = "${aws_ecr_repository.cloud_inventory_scraper.repository_url}:latest"
          environment = [
              {
                  name = "PARQUET_S3_BUCKET"
                  value = var.inventory_bucket_name
              },
              {
                  name = "AWS_ACCOUNTS"
                  value = "306526781466,166953723888,055185845477,023611290521,261108431719,536809099843"
              },
              {
                  name = "AWS_ASSUME_ROLE_NAME"
                  value = var.assume_role_name
              }
          ]
          logConfiguration = {
              logDriver = "awslogs"
              options = {
                  awslogs-group = aws_cloudwatch_log_group.inventory_scraper.name
                  awslogs-region = data.aws_region.current.name
                  awslogs-stream-prefix = "scraper"
              }
          }
      }
  ])

  cpu                = var.scraper_cpu_units
  memory             = var.scraper_memory_units
  task_role_arn      = aws_iam_role.cloud_inventory_scraper_task_role.arn
  execution_role_arn = aws_iam_role.cloud_inventory_scraper_task_execution_role.arn
}