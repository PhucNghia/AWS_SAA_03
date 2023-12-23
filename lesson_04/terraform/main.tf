/*
- requirement:
  - Create VPC
  - Create EC2
  - Attach EBS to EC2
  - Create AMI from exists EC2 instance
*/
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30.0"
    }
  }
}

provider "aws" {
  region                   = var.region
  profile                  = "nghiapn2"
  shared_credentials_files = ["/home/nghiapn2/.aws/credentials"]
}

module "vpc" {
  source = "./VPC"
}

module "ec2" {
  source        = "./EC2_Wordpress"
  custom_vpc_id = module.vpc.custom_vpc_id
  subnet_ids    = module.vpc.subnet_ids
}

module "ebs" {
  source           = "./EBS"
  ec2_instance_ids = module.ec2.ec2_instance_ids
  azs              = module.vpc.azs
}

module "ami" {
  source           = "./AMI"
  ec2_instance_ids = module.ec2.ec2_instance_ids
}
