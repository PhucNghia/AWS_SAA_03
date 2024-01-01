provider "aws" {
  region                   = var.region
  profile                  = "nghiapn2"
  shared_credentials_files = ["/home/nghiapn2/.aws/credentials"]
}

module "provision" {
  source = "./provision"
}
