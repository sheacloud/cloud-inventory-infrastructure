resource "aws_ecr_repository" "cloud_inventory_scraper" {
  name                 = "cloud-inventory-scraper"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}