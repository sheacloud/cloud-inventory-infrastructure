resource "aws_cloudwatch_event_rule" "cloud_inventory_scraper" {
  name        = "cloud-inventory-scraper"
  description = "Initiate a cloud inventory scrape"

  schedule_expression = "rate(${var.scrape_frequency})"
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  arn       = aws_ecs_cluster.cloud_inventory.arn
  rule      = aws_cloudwatch_event_rule.cloud_inventory_scraper.name
  role_arn  = aws_iam_role.cloud_inventory_scraper_events_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.cloud_inventory_scraper.arn
    launch_type = "FARGATE"
    network_configuration {
      subnets = var.subnet_ids
      security_groups = [aws_security_group.cloud_inventory_scraper.id]
      assign_public_ip = var.ecs_assign_public_ip
    }
  }
}