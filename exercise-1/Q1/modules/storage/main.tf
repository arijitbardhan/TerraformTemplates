terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_ebs_volume" "instance_storage" {
  availability_zone = var.availability_zone 
  size              = var.size         # Specify the size of the volume in GiB

  tags = {
    Name = "${var.instance_name}_EBS"
  }
}

resource "aws_volume_attachment" "ebs_attachment_to_ec2" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.instance_storage.id
  instance_id = var.instance_id
}