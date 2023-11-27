/*
Modules:
  + iam: Create IAM User + Policy + Role and Attach them
  + s3: Create s3 bucket
*/

provider "aws" {
  profile                  = "default_profile"
  region                   = var.region
  shared_credentials_files = ["/home/nghiapn2/workspace/aws/.config/credentials"]
}

module "iam" {
  source = "./iam"
}

module "s3" {
  source = "./s3"
}
