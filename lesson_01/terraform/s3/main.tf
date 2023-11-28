/*
    Create S3 Bucket
*/

resource "aws_s3_bucket" "bucket_nghiapn3" {
  bucket = "bucket-nghiapn3"

  tags = {
    Name = "bucket-nghiapn3"
  }
}
