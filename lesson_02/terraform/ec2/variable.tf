variable "ami" {
  type    = string
  default = "ami-0fc5d935ebf8bc3bc"

}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "custom_vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}
