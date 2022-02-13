resource "aws_ecs_cluster" "cloud_inventory" {
  name = "cloud-inventory"

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 1
  }

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}