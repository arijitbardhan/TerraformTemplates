terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Defining AWS provider config
provider "aws" {
  region  = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

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

# Key Pair resource for accessing EC2 instance
resource "aws_key_pair" "app_server_instance_key" {
  key_name   = "${var.instance_name}_key"
  public_key = trimspace(tls_private_key.ssh_key_pair_data.public_key_openssh)    # Generating public key data through tls_private_key resource at root level
  #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjjRLbp1E33tjqSgvJdPy0d0O0skPuUuUHg98u4EDoYR5J1B5MLjiTao1AAtdngilUxHv7bXHbVSJCEbH9/6+Xs3gug8TThhuNfqcDt4r/SxKVshiaDd/iK1pFFo0YxXc47n0111zuanhKoDt/pUCrJ1h84lfoBEp7cUBnlrYa5vi1qApMOffHmlOwdMihJhIVXq+Y0br7rRMirAgfZtTn8Qeg3xnxRtrrFmKIdvvegnY86pTHCAnqiYWWytbKEazXopAJcR+kT6MHLEsco/w7ImP/3pu8yIqQYjjvD8ynyw17L663AIryuEPG4a623xLcKsR4GdTZl5mAwJpmnQBrIYfOhziW6EXNXCVUUbFfVPtMMtJa+xHqAmBYYKe/t71Afa0iB35liP+lYGJ+IsM980JbGAkQLQWPEr/iv67hhhMv8FlAsnVJciGwenWYDGZ0wR8vUrHrmAOdsnynFhUP9etuOn+s6iPAL40VzUrqRlUdX8XjmQg2Qr2a5zPbNV/x/+I7NIZk3RLQVFlHNSdOOsl6tNYYjJE+n4s0oejlBG+sxS53IJrHgCfmKIPkl9M0pS/BjTix3fg8OeFzmXKIuAO53dObvbD7WO2DH/cASpHLlyxfiH/sbiYmqqonKhEzJL3wb54FrwpETQ3P6utFXedcWLh0/lpN/HSF7d0E9Q== ubuntu@ip-172-31-46-136"
}

#EC2 configurations
resource "aws_instance" "app_server_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
    
  tags = {
    Name = var.instance_name
  }

  key_name = aws_key_pair.app_server_instance_key.key_name

  # defining storage
  root_block_device {
    delete_on_termination = var.root_block_device_delete_on_termination
    encrypted             = var.root_block_device_encrypted
    volume_size           = var.root_block_device_volume_size
    volume_type           = var.root_block_device_volume_type
  }

  network_interface {
    device_index          = var.ec2_network_interface_device_index
    #network_interface_id  = aws_network_interface.app_server_nic.id
    network_interface_id = module.app_server_nic.nic_id
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "app_server_vpc" {
  cidr_block = var.app_server_vpc_cidr_block
  
  tags = {
    Name = "${var.instance_name}_VPC"
  }
}

resource "aws_subnet" "app_server_subnet" {
  vpc_id                  = aws_vpc.app_server_vpc.id
  cidr_block              = cidrsubnet(var.app_server_vpc_cidr_block, 8, 15)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = var.app_server_subnet_public_ip
  tags = {
    Name = "${var.instance_name}_Subnet"
  }
}

module "app_server_nic" {
  source        = "./modules/network-interface"
  subnet_id     = aws_subnet.app_server_subnet.id
  private_ips   = [ cidrhost(aws_subnet.app_server_subnet.cidr_block, 10) ]
  instance_name = var.instance_name
  access_key    = var.access_key
  secret_key    = var.secret_key
  region        = var.region
}

# resource "aws_network_interface" "app_server_nic" {
#   subnet_id   = aws_subnet.app_server_subnet.id
#   private_ips = [ cidrhost(aws_subnet.app_server_subnet.cidr_block, 10) ]
  
#   tags = {
#     Name = "${var.instance_name}_NetworkInterfaceCard"
#   }
# }

resource "aws_security_group" "vpc_security_group" {
  name        = "Allow_Ingress_Ports"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.app_server_vpc.id

  tags = {
    Name = "Allow_Ingress_Ports"
  }

  dynamic "ingress" {
    for_each = var.security_group_ingress_ports
    content {
      protocol    = "tcp"
      from_port   = ingress.value[0]
      to_port     = ingress.value[1]
      cidr_blocks = ingress.value[2]
    }
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.vpc_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.vpc_security_group.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_network_interface_sg_attachment" "sg_attachment_ec2" {
  security_group_id     = aws_security_group.vpc_security_group.id
  network_interface_id  = module.app_server_nic.nic_id
  #network_interface_id  = aws_network_interface.app_server_nic.id
}

resource "aws_ebs_volume" "instance_storage" {
  availability_zone = data.aws_availability_zones.available.names[0] 
  size              = var.root_block_device_volume_size         # Specify the size of the volume in GiB

  tags = {
    Name = "${var.instance_name}_EBS"
  }
}

resource "aws_volume_attachment" "ebs_attachment_to_ec2" {
  device_name = var.ebs_attachment_to_ec2_device_name
  volume_id   = aws_ebs_volume.instance_storage.id
  instance_id = aws_instance.app_server_instance.id
}