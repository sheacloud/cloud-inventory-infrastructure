resource "aws_glue_catalog_database" "cloud_inventory" {
  name = "cloud-inventory"
}

module "cloud_inventory_glue_tables" {
  source             = "./../../../cloud-inventory/terraform/glue/"
  s3_bucket_name     = aws_s3_bucket.cloud_inventory.bucket
  glue_database_name = aws_glue_catalog_database.cloud_inventory.name
}

