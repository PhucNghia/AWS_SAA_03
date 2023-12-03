resource "aws_organizations_account" "account" {
  name      = var.account_name
  email     = var.email_address
  role_name = var.role_name # owner
  tags = {
    "terraform-managed" : true
  }
}

resource "aws_iam_account_alias" "alias" {
  provider      = aws.sub-account
  account_alias = var.account_name
}

