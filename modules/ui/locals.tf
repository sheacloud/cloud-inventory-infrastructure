locals {
  hostname = "cloud-inventory"
  fqdn     = "${local.hostname}.${var.public_domain_name}"
}