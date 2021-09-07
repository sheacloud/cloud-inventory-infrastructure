variable "vpc_id" {
    type = string
}

variable "subnet_ids" {
    type = list(string)
}

variable "ecs_assign_public_ip" {
    type = bool
    default = true
}

variable "inventory_bucket_name" {
    type = string
}

variable "assume_role_name" {
    type = string
}

variable "scraper_cpu_units" {
    type = number
    default = 256
}

variable "scraper_memory_units" {
    type = number
    default = 512
}

variable "scrape_frequency" {
    type = string
}