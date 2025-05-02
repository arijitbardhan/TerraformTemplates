terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = ""
    region = ""
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "app_server_vpc" {
  cidr_block = var.vpc_cidr_block
  
  tags = {
    Name = "${var.instance_name}_VPC"
  }
}

resource "aws_subnet" "app_server_subnet" {
  vpc_id            = aws_vpc.app_server_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = "${var.instance_name}_Subnet"
  }
}
