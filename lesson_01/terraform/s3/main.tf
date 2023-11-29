/*
    Create S3 Bucket
*/

resource "aws_s3_bucket" "bucket_danlv3" {
  bucket = "bucket-danlv3"

  tags = {
    Name = "bucket-danlv3"
  }
}
