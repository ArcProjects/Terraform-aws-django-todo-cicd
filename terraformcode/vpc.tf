#VPC Creation
resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "10.200.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "jenkins_VPC"
  }

}

#Subnet Creation
resource "aws_subnet" "jenkins_public_subnet" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "10.200.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "jenkins-public"
  }
}

#Internet GW IGW Creation
resource "aws_internet_gateway" "jenkins_internet_gateway" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "jenkins_igw"
  }
}

#Route Table Creation
resource "aws_route_table" "jenkins_public_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "jenkins_public_rt"
  }
}

#Route Inside a Route Table
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.jenkins_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.jenkins_internet_gateway.id
}

#Route Table Assosisation with Subnet
resource "aws_route_table_association" "jenkins_public_assoc" {
  subnet_id      = aws_subnet.jenkins_public_subnet.id
  route_table_id = aws_route_table.jenkins_public_rt.id
}
