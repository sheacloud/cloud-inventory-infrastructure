resource "aws_cloudwatch_event_rule" "cloud_inventory_fetcher" {
  name        = "cloud-inventory-fetcher"
  description = "Initiate a cloud inventory fetch"

  schedule_expression = "rate(${var.scrape_frequency})"
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  arn      = aws_ecs_cluster.cloud_inventory.arn
  rule     = aws_cloudwatch_event_rule.cloud_inventory_fetcher.name
  role_arn = aws_iam_role.cloud_inventory_fetcher_events_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.cloud_inventory_fetcher.arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = var.subnet_ids
      security_groups  = [aws_security_group.cloud_inventory_fetcher.id]
      assign_public_ip = var.ecs_assign_public_ip
    }
  }
}