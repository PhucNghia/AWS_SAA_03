/*
    Prepare: Fetch org data
    Step 1: Enable Service control policies
    Step 2: Create SCP
    Step 3: Attach SCP to OU
*/

# Prepare: Fetch org data
data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_units" "ou" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

locals {
  develop_ou = [
    for x in data.aws_organizations_organizational_units.ou.children[*] :
    x if x.name == var.develop_ou
  ][0]
}

# Step 1: Enable Service control policies
/*
  1. go to https://us-east-1.console.aws.amazon.com/organizations/v2/home/policies page
  2. then Enable "Service control policies"
*/

# Step 2: Create SCP
resource "aws_organizations_policy" "org_policy" {
  name = "org_policy"
  content = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "*",
          "Resource" : "*"
        },
        {
          "Effect" : "Deny",
          "Action" : "ec2:*",
          "Resource" : "*"
        }
      ]
    }
  )
}

# Step 3: Attach SCP to OU
resource "aws_organizations_policy_attachment" "org_policy_attach" {
  policy_id = aws_organizations_policy.org_policy.id
  target_id = local.develop_ou.id
}
