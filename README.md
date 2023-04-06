# django-todo using Terraform and Jenkins 
#Deploy the AWS Infrastructure using Terraform

![Architecture](https://github.com/ArcProjects/Terraform-aws-django-todo-cicd/blob/main/images/djangotodo.png)



 Terraform to create various resource such as Vpc, Subnet, Route table , Security group and EC2 instance.



 ```**Click on the blue highlighed text to know more information in each section.** | ```

- - -

## Steps

[1. IAM Setup](#1-iam-setup)

[2. Environment Setup](#2-environment-setup)

[3. Install Terraform](#3-install-terraform)

[4. AWS Provider & Authentication](#4-aws-provider--authentication)

[5. VPC Creation](#5-vpc-creation)

[6. Subnet Creation](#6-subnet-creation)

[7. Security Group Creation](#7-security-group-creation)

[8. Ami Datasource Configuration](#8-ami-datasource-configuration)

[9. key Pair Creation](#9-key-pair-creation)

[10. Ec2 Instance Creation](#10-ec2-instance-creation)

[11. User Data](#11-user-data)

[12. SSH Configuration](#12-ssh-configuration)
- - - - -
- - -----

### 1. IAM Setup
* Login to Aws Console - https://My_AWS_Account_ID.signin.aws.amazon.com/console/
* [create a user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) with admin privilages
* [Create new access keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) and download .csv file

### 2. Environment Setup

* [Install vscode](https://My_AWS_Account_ID.signin.aws.amazon.com/console/)
* Install Terraform, Aws Toolkit , Remote SSH Plugins.

![terraform](https://github.com/ArcProjects/Terraform-aws-django-todo-cicd/blob/main/images/vsterra.png)
![aws toolkit](https://github.com/ArcProjects/Terraform-aws-django-todo-cicd/blob/main/images/awstoolkit.png)
![Remote-SSH Plugins](https://github.com/ArcProjects/Terraform-aws-django-todo-cicd/blob/main/images/ssh%20plugins.png)



### 3. Install Terraform

* [Download and install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* Create a terraform directory and initialise terraform using **terraform init** command 
![init](https://github.com/ArcProjects/Terraform-aws-django-todo-cicd/blob/main/images/init.png)

### 4. AWS Provider & Authentication

* [Create a file provider.tf  and add the provider](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
```
* For authentication we can use many methods -more information follow the [link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). In this project i will be using the shared credential file. 
  * Parameters in the provider configuration
  * Environment variables
  * Shared credentials files
```
#authentication in provider.tf using shared credntial file
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "sim"
} 
```
  * Shared configuration files
  * Container credentials
  * Instance profile credentials and region

You can configure the credentials directly by going in to .aws folder and edit Shared configuration files put your acess keys , secrets and profile name or use vscode to create the credential profile

![aws folder](https://github.com/ArcProjects/Terraform-aws-django-todo-cicd/blob/main/images/awsfolder.png)

![vs code cred manager](https://github.com/ArcProjects/Terraform-aws-django-todo-cicd/blob/main/images/createcred.png)


### 5. VPC Creation
```
#VPC Creation
resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "10.200.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "jenkins_VPC"
  }

}
```

### 6. Subnet Creation
```
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

```

### 7. Security Group Creation

```
#Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "public_sg"
  description = "public security group"
  vpc_id      = aws_vpc.jenkins_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 8. Ami Datasource Configuration
Create a new file called datasource.tf and create ami data which will be refernced while crearting new EC2
```
data "aws_ami" "amzlin_ami" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

}
```

### 9. key Pair Creation

```
#Key Pair Generation
resource "aws_key_pair" "ntc_auth" {
  key_name   = "jenkinskey"
  public_key = file("~/.ssh/ntckey.pub")
}
```

### 10. Ec2 Instance Creation

```
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
```

### 11. User Data 
create userdata.tpl file . This file will be used to install softwares needed after the first boot

```
#!/bin/bash

sudo yum update -y

sudo yum install -y wget

sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo   

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum install -y java-11-amazon-corretto-headless

sudo yum install -y java-11-amazon-corretto

sudo yum install -y java-11-amazon-corretto-devel

sudo yum upgrade -y

sudo yum install jenkins -y

sudo systemctl enable jenkins

sudo systemctl start jenkins

sudo systemctl status jenkins

sudo yum install git -y
sudo su 
cd /home

sudo mkdir projects

cd projects 
sudo mkdir django-todo
cd django-todo 
sudo chmod 777 projects/*

sudo yum install git -y
git init
git clone https://github.com/ArcProjects/django-todo-cicd.git

sudo yum search docker
sudo yum info docker
sudo yum install docker
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl status docker.service
sudo usermod -a -G docker ec2-user
reboot
```

### 12. plan and validation 
[Terraform plan](https://developer.hashicorp.com/terraform/cli/commands/apply)  creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.Vaildates the code you have written, if there is any error while defining any resources will be highlighted.

[Terraform apply](https://developer.hashicorp.com/terraform/cli/commands/apply) The terraform apply command executes the actions proposed in a Terraform plan. Will send the request to aws to build or deploy the resource mentioned in the terraform plan.

[Terraform state list](https://developer.hashicorp.com/terraform/cli/commands/state/list) The command will list all resources in the state file matching the given addresses (if any). If no addresses are given, all resources are listed.

![imvalid arg](https://github.com/ArcProjects/Terraform-aws-django-todo-cicd/blob/main/images/invalidarg.png)

![deployed]https://github.com/ArcProjects/Terraform-aws-django-todo-cicd/blob/main/images/ec2deployed.png



[Terraform destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy) will destroy the complete resources which was planned and applied.

![destroy](https://github.com/ArcProjects/Terraform-aws-django-todo-cicd/blob/main/images/destroy.png)



### 13. ssh configuration and console access 

```
ssh -i "~/.ssh/mtckey" ec2-user
```
=======
Deploy AWS instance using Terraform and VS code and take remote ssh using vs code and access the files.

### 14. Configure Jenkins

* Goto to http://ip-addr>:8080 
* Fetch the  inital password  from this command cat /var/lib/jenkins/secrets/initialAdminPassword
* Login with password and create the admin credential
* Install the plugins recommended on the window 
* 








# A simple todo app built with django deploy on windows

![todo App](https://raw.githubusercontent.com/shreys7/django-todo/develop/staticfiles/todoApp.png)
### Setup
To get this repository, run the following command inside your git enabled terminal
```bash
$ git clone https://github.com/shreys7/django-todo.git
```
You will need django to be installed in you computer to run this app. Head over to https://www.djangoproject.com/download/ for the download guide

Once you have downloaded django, go to the cloned repo directory and run the following command

```bash
$ python manage.py makemigrations
```

This will create all the migrations file (database migrations) required to run this App.

Now, to apply this migrations run the following command
```bash
$ python manage.py migrate
```

One last step and then our todo App will be live. We need to create an admin user to run this App. On the terminal, type the following command and provide username, password and email for the admin user
```bash
$ python manage.py createsuperuser
```

That was pretty simple, right? Now let's make the App live. We just need to start the server now and then we can start using our simple todo App. Start the server by following command

```bash
$ python manage.py runserver
```

Once the server is hosted, head over to http://127.0.0.1:8000/todos for the App.

Cheers and Happy Coding :)
"# Terraform-aws-django-todo-cicd" 
