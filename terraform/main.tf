terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "mdc-rg"
    storage_account_name = "mdcconfigid" # YOUR STORAGE ACCOUNT NAME
    container_name       = "tfstates"
    key                  = "terraform-aws.tfstate"
    use_oidc             = true
  }

}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] ## Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

data "aws_ami" "centos" {
  most_recent = true
  owners = ["137112412989"] ## Canonical TESTE SE ESTA AUTOMATICO

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_default_vpc" "default" {}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  #var.operating_system == "ubuntu" ? data.aws_ami.latest_ubuntu.id : data.aws_ami.latest_centos.id
  instance_type = "t3.micro"
  key_name      = "terraform-mdc"
  vpc_security_group_ids      = [aws_security_group.ssh.id]


  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_security_group" "ssh" {
  name        = "allow_ssh_ga"
  description = "Allow ssh inbound traffic"
  vpc_id = aws_default_vpc.default.id

  ingress {
    description      = "WebServer from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}