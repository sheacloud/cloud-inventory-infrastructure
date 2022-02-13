terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "fetcher" {
  source = "./modules/fetcher"

  assume_role_name          = var.assume_role_name
  fetcher_cpu_units         = var.fetcher_cpu_units
  fetcher_memory_units      = var.fetcher_memory_units
  scrape_frequency          = var.scrape_frequency
  cloud_inventory_s3_bucket = module.database.cloud_inventory_s3_bucket
  ecs_assign_public_ip      = var.ecs_assign_public_ip
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  cloud_inventory_aws_account_ids = var.cloud_inventory_aws_account_ids
}

module "database" {
  source = "./modules/database"

  s3_bucket_prefix = var.s3_bucket_prefix
}

module "api" {
  source                    = "./modules/api"
  public_domain_name        = var.public_domain_name
  cloud_inventory_s3_bucket = module.database.cloud_inventory_s3_bucket
}

module "ui" {
  source             = "./modules/ui"
  public_domain_name = var.public_domain_name
  bucket_prefix      = var.s3_bucket_prefix
}