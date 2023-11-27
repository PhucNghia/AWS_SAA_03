/*
Create S3 Bucket 

Steps:
  1. Create S3 Bucket
  2. Create IAM Policy: AllowS3Access
*/

resource "aws_s3_bucket" "nghiapn3_bucket" {
  bucket = "nghiapn3-bucket"

  tags = {
    Name = "nghiapn3-bucket"
  }
}
