resource "aws_cloudwatch_log_group" "inventory_fetcher" {
  name = "/ecs/cloud-inventory/fetcher"
}