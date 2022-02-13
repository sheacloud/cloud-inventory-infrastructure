resource "aws_acm_certificate" "cloud_inventory" {
  domain_name       = "${local.hostname}.${var.public_domain_name}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "cloud_inventory" {
  certificate_arn         = aws_acm_certificate.cloud_inventory.arn
  validation_record_fqdns = [for record in aws_route53_record.cloud_inventory_validation : record.fqdn]
}