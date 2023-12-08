/*
  prepare: 
    + go to AWS Organizations -> create an organization
    + Fetch org data by terraform
  Step 1. Create Role (assume root account)
  Step 2. Attach Policy to Role
  Step 3. Create Organization Unit
  Step 4. Create an org account into OU with role has been created before
*/

# Prepare: Fetch org data
data "aws_organizations_organization" "org" {}

# Step 1. Create Role
resource "aws_iam_role" "this" {
  name = "Developer"

  assume_role_policy = data.template_file.trust_relationship.rendered
}

data "template_file" "trust_relationship" {
  template = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "${var.trusted_arn_entity}"
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {}
        }
      ]
    }
  )
}

# Step 2. Attach Policy to Role
resource "aws_iam_role_policy_attachment" "administrator_access" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.this.name
}

# Step 3. Create Organization Unit
resource "aws_organizations_organizational_unit" "develop" {
  name      = var.develop_ou
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

# Step 4. Create an org account into OU with role has been created before
resource "aws_organizations_account" "DEV" {
  name      = var.dev_account_name
  email     = var.dev_email_address
  role_name = aws_iam_role.this.name
  parent_id = aws_organizations_organizational_unit.develop.id
}
