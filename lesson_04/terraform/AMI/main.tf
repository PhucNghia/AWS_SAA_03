resource "aws_ami_from_instance" "ami" {
  name               = "terraform-ami"
  source_instance_id = element(var.ec2_instance_ids, 0)
}
