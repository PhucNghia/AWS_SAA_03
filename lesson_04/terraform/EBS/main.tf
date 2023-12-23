/*
    Step 1: Create an ebs
    Step 2: Attach ebs to ec2
*/
resource "aws_ebs_volume" "ebs" {
  availability_zone = element(var.azs, 0)
  size              = 2

  tags = {
    Name = "my EBS"
  }
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = element(var.ec2_instance_ids, 0)
}
