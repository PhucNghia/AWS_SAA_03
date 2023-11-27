/*
Create IAM User + Policy + Role and Attach them

Steps:
  1. Create IAM User: NghiaPN3
  2. Create IAM Policy: AllowS3Access
  3. Create IAM Role: NghiaPN3Role
  4. Attach IAM Role & Policy: NghiaPN3Role + AllowS3Access
  5. Attach IAM User & Policy: NghiaPN3 + AllowS3Access
  6. return Access_key and Cecret_key
*/

# 1. Create IAM user
resource "aws_iam_user" "nghiapn3" {
  name = "NghiaPN3"
}

# 2. Create IAM Policy
resource "aws_iam_policy" "allow_s3_access" {
  name        = "AllowS3Access"
  description = "Allow NghiaPN3 to access specific S3 resources"
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
          "arn:aws:s3:::bucket-nghiapn3",
          "arn:aws:s3:::bucket-nghiapn3/*"
        ]
      }
    ]
  })
}

# 3. Create IAM Role
resource "aws_iam_role" "nghiapn3_role" {
  name = "NghiaPN3Role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "s3.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# 4. Attaching the IAM Role to IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "attach_s3_access" {
  policy_arn = aws_iam_policy.allow_s3_access.arn
  role       = aws_iam_role.nghiapn3_role.name
}

# 5. Attaching the IAM user to IAM Policy
resource "aws_iam_user_policy_attachment" "nghiapn3_s3_access" {
  user       = aws_iam_user.nghiapn3.name
  policy_arn = aws_iam_policy.allow_s3_access.arn
}

# 6. return Access_key and Cecret_key
resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.nghiapn3.name
}

output "secret_key_nghiapn3" {
  value     = aws_iam_access_key.access_key.secret
  sensitive = true
}

output "access_key_nghiapn3" {
  value = aws_iam_access_key.access_key.id
}
