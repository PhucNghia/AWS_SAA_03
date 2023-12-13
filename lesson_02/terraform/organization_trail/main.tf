/*
Setup
    - Enable for all account in my org
    - create new s3 bucket
    - Log file SSE-KMS: disable
    - Log file validation: enable
    - SNS notification delivery: disable
    - Create IAM Role: CloudTrailRoleForCloudWatchLogs
    - Event type: Management Events
    - API activity: Read + Write
*/

resource "aws_s3_bucket" "bucket_danlv3" {
  bucket = "bucket-danlv3-cloudtrail"

  tags = {
    Name = "bucket-danlv3-cloudtrail"
  }
}

resource "aws_cloudtrail" "my-cloudtrail" {
  name                       = "my-cloudtrail"
  s3_bucket_name             = aws_s3_bucket.bucket_danlv3.bucket
  enable_log_file_validation = true
}
