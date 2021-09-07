# cloud-inventory-infrastructure
IaC for deploying cloud-inventory to an AWS environment using Fargate

## Usage

To deploy cloud-inventory to an AWS account, create a terraform template similar to:

main.tf
```hcl
provider "aws" {
    region = "us-east-1"
}

module "database" {
    source = "git::https://github.com/sheacloud/cloud-inventory/terraform/"
    bucket_name = "my-inventory-bucket-name"
}

module "infrastructure" {
    source = "git::https://github.com/sheacloud/cloud-inventory-infrastructure/"

    vpc_id = "vpc-abcd1234"
    subnet_ids = ["subnet-abcd1234", "subnet-efgh5678"]
    ecs_assign_public_ip = true
    inventory_bucket_name = "my-inventory-bucket-name"
    assume_role_name = "my-iam-role-to-assume"
    scrape_frequency = "30 minutes"
}
```