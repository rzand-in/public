resource "aws_s3_bucket" "s3_learn_aws" {
  bucket = "accau1-s3-demo-bucket-terraform"

  tags = {
    method      = "terraform"
    environment = "dev"
  }
}