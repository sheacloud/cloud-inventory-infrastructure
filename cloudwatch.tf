resource "aws_cloudwatch_log_group" "inventory_scraper" {
  name = "/ecs/cloud-inventory/scraper"
}