variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}
variable "linux_ami_id" {
  default = "ami-016eb5d644c333ccb"

}

variable "os_type" {
  type        = string
  description = "values can be | amzlin | linux | ubuntu based on this user data file will be taken "

}


output "dev_ip" {
  value = aws_instance.jenkins_node.public_ip
}

