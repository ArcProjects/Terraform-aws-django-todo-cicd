
data "aws_ami" "amzlin_ami" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

}

# ubuntu1
/*data "aws_ami" "ubuntu_ami" {s
  most_recent = true
  owners      = ["099720109477"]
  

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}*/

# Redhat Linux
data "aws_ami" "linux_ami" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-*"]
  }

}
