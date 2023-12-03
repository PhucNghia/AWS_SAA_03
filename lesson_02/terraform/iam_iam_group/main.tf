/*
  Create IAM User + IAM Group + Policy and Attach them

  Steps:
    1. Create IAM User: NghiaPN3
    2. Create IAM Group: s3_group
    3. Add User to Group: NghiaPN3 + s3_group
    4. Create IAM Policy: AllowS3Access
    5. Attach IAM Policy to IAM Group: AllowS3Access + s3_group
    6. Get + Save Access_key and Cecret_key
*/

# 1. Create IAM user
resource "aws_iam_user" "nghiapn3" {
  name = "NghiaPN3"
}

# 2. Create IAM Group: s3_group
resource "aws_iam_group" "s3_group" {
  name = "s3_group"
}

# 3. Add User to Group
resource "aws_iam_user_group_membership" "user_group" {
  user = aws_iam_user.nghiapn3.name

  groups = [
    aws_iam_group.s3_group.name
  ]
}

# 4. Create IAM Policy
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

# 5. Attach IAM Policy to IAM Group: AllowS3Access + s3_group
resource "aws_iam_group_policy_attachment" "group_policy" {
  group      = aws_iam_group.s3_group.name
  policy_arn = aws_iam_policy.allow_s3_access.arn
}

# 6. Get + Save Access_key and Cecret_key
resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.nghiapn3.name
}

resource "local_file" "private_key" {
  content  = format("%s / %s", aws_iam_access_key.access_key.id, aws_iam_access_key.access_key.secret)
  filename = "${path.module}/${aws_iam_user.nghiapn3.name}_credentials.txt"
}
