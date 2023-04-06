

#Key Pair import
resource "aws_key_pair" "jenkins_auth" {
  key_name   = "jenkinskey"
  public_key = file("~/.ssh/mtckey.pub")
}

# Instance Creation
resource "aws_instance" "jenkins_node" {
  instance_type = "t2.micro"
  /*ami   = "var.ami"*/ # Deploy with variable
  ami = data.aws_ami.amzlin_ami.id
  key_name = aws_key_pair.jenkins_auth.id
  # Assigns security group to EC2 instance allowing traffic on port 22 and 8080
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.jenkins_public_subnet.id
  # Assigns IAM role to EC2 instance
  /*iam_instance_profile = aws_iam_instance_profile.jenkins-s3-instance-profile.id*/
  #https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/amazon-linux-install.html
  user_data = file("${var.os_type}-userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "jenkins-node"
  }
}