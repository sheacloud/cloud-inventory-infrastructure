resource "aws_s3_bucket" "cloud_inventory" {
  bucket = "${var.s3_bucket_prefix}-cloud-inventory"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloud_inventory" {
  bucket = aws_s3_bucket.cloud_inventory.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "athena_query_results" {
  bucket = "${var.s3_bucket_prefix}-cloud-inventory-query-results"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_query_results" {
  bucket = aws_s3_bucket.athena_query_results.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}