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
    










