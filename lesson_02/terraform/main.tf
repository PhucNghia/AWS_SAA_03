/*
- requirement:
  - vpc & ec2:
    + Diagram: https://drive.google.com/file/d/11T-fm8HkKK4me6VSxykf2D6T0RKLQzuH/view?usp=sharing
    + can ssh to "public ec2-01" instance from local machine
    + can ssh to "internal ec2-01" instance from "public ec2-01" instance
  - cloudwatch:
    + cloudwatch metric alarm for ec2-01 instance
  - route53:
    + buy a domain (nghiapn.pro) with namecheap.com (3$)
    + add domain to hosted zones with aws
  
  - s3:
    + create a bucket 
  - iam user & iam group
    + create iam user
    + create iam group -> add iam user to iam group
    + create policy access to s3
    + attach policy to iam group
  - aws_organization
    + create an organization account & can switch role
  - service_control_policies
    + create scp and attach to OU
  - organization_trail
    + TODO
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
  source = "./vpc"
}

module "ec2" {
  source             = "./ec2"
  custom_vpc_id      = module.vpc.custom_vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "cloudwatch" {
  source             = "./cloudwatch"
  ec2_instance_ids   = module.ec2.ec2_instance_ids
  ec2_instance_names = module.ec2.ec2_instance_names
}

module "route53" {
  source                  = "./route53"
  ec2_instance_public_ips = module.ec2.ec2_instance_public_ips
}

module "s3" {
  source = "./s3"
}

module "iam_iam_group" {
  source = "./iam_iam_group"
}

module "aws_organization" {
  source = "./aws_organization"
}


module "service_control_policies" {
  source     = "./service_control_policies"
  develop_ou = module.aws_organization.develop_ou
}

/* TODO
module "organization_trail" {
}
*/
