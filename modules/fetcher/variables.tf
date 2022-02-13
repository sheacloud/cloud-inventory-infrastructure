variable "assume_role_name" {
  type = string
}

variable "fetcher_cpu_units" {
  type    = number
  default = 256
}

variable "fetcher_memory_units" {
  type    = number
  default = 512
}

variable "scrape_frequency" {
  type = string
}

variable "cloud_inventory_s3_bucket" {
  type = string
}

variable "ecs_assign_public_ip" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "cloud_inventory_aws_account_ids" {
  type = string
}