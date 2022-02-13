resource "aws_security_group" "cloud_inventory_fetcher" {
  name        = "cloud-inventory-fetcher-task-sg"
  description = "Allow outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "cloud-inventory-fetcher-task-sg"
  }
}

resource "aws_security_group_rule" "cloud_inventory_fetcher_egress" {
  security_group_id = aws_security_group.cloud_inventory_fetcher.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}