variable "ami" {
  type    = string
  default = "ami-079db87dc4c10ac91" # Amazon Linux 2023 AMI 2023.3.20231218.0 x86_64 HVM kernel-6.1
  # default = "ami-0fc5d935ebf8bc3bc" # Ubuntu
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "custom_vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

