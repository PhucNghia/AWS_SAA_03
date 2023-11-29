/*
- Create an IAM user and grant access with s3 
- Modules:
  + iam: Create IAM User + Policy and Attach them
  + s3: Create s3 bucket
*/

provider "aws" {
  profile                  = "danlv3"
  region                   = var.region
  shared_credentials_files = ["/home/danlv3/.aws/credentials"]
}

module "s3" {
  source = "./s3"
}
