/*
- Create an IAM user and grant access with s3 
- Modules:
  + iam: Create IAM User + Policy and Attach them
  + s3: Create s3 bucket
*/

provider "aws" {
  profile                  = "nghiapn2"
  region                   = var.region
  shared_credentials_files = ["/home/nghiapn2/.aws/credentials"]
}

module "iam" {
  source = "./iam"
}

module "s3" {
  source = "./s3"
}
