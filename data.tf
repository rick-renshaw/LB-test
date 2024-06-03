data "aws_ami" "ami" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
  owners = ["Amazon"]
}