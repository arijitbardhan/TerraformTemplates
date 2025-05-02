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

# for getting AMI id
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "ssh_key_pair_data" {
  algorithm = "RSA"
  rsa_bits  = 2048    # Maximum length of allowed for key_pair
}

module "ec2_instance" {
  source                                  = "./modules/ec2-instance"
  access_key                              = var.access_key
  secret_key                              = var.secret_key
  region                                  = var.region
  instance_name                           = var.instance_name
  instance_type                           = var.instance_type
  root_block_device_delete_on_termination = var.root_block_device_delete_on_termination
  root_block_device_encrypted             = var.root_block_device_encrypted
  root_block_device_volume_size           = var.root_block_device_volume_size
  root_block_device_volume_type           = var.root_block_device_volume_type
  public_key                              = trimspace(tls_private_key.ssh_key_pair_data.public_key_openssh)
  ami                                     = data.aws_ami.ubuntu.id
  device_index                            = var.ec2_network_interface_device_index
  network_interface_id                    = module.network.nic_id
}

module "storage" {
  source            = "./modules/storage"
  access_key        = var.access_key
  secret_key        = var.secret_key
  region            = var.region
  availability_zone = var.instance_storage_availability_zone
  size              = var.instance_storage_size
  instance_name     = var.instance_name
  device_name       = var.ebs_attachment_to_ec2_device_name
  instance_id       = module.ec2_instance.ec2_instance_id
}

module "network" {
  source = "./modules/network-services"
  access_key              = var.access_key
  secret_key              = var.secret_key
  region                  = var.region
  vpc_cidr_block          = var.app_server_vpc_cidr_block
  instance_name           = var.instance_name
  subnet_cidr_block       = var.app_server_subnet_cidr_block
  map_public_ip_on_launch = var.app_server_subnet_public_ip
}