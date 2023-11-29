/*
  Create IAM User + Policy and Attach them

  Steps:
    1. Create IAM User: DanLv3
    2. Create IAM Policy: AllowS3Access
    3. Attach IAM User & Policy: DanLv3 + AllowS3Access
    4. return Access_key and Cecret_key
*/

# 1. Create IAM user
resource "aws_iam_user" "danlv3" {
  name = "DanLv3"
}

# 2. Create IAM Policy
resource "aws_iam_policy" "allow_s3_access" {
  name        = "AllowS3Access"
  description = "Allow DanLv3 to access specific S3 resources"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::bucket-danlv3",
          "arn:aws:s3:::bucket-danlv3/*"
        ]
      }
    ]
  })
}

# 3. Attaching the IAM user to IAM Policy
resource "aws_iam_user_policy_attachment" "danlv3_s3_access" {
  user       = aws_iam_user.danlv3.name
  policy_arn = aws_iam_policy.allow_s3_access.arn
}

# 4. return Access_key and Cecret_key
resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.danlv3.name
}

output "secret_key_danlv3" {
  value     = aws_iam_access_key.access_key.secret
  sensitive = true
}

output "access_key_danlv3" {
  value = aws_iam_access_key.access_key.id
}
