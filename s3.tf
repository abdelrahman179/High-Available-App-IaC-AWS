resource "aws_s3_bucket" "app-s3" {
  bucket = "app-bucket"
  force_destroy = true
  region = var.AWS_REGION
  tags = {
      Name = "${var.ENVIRONMENT}-app-s3-bucket"
  }
}

