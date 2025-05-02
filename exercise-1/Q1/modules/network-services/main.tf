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

resource "aws_network_interface" "app_server_nic" {
  subnet_id   = aws_subnet.app_server_subnet.id
  private_ips = ["10.0.0.100"]
  
  tags = {
    Name = "${var.instance_name}_NetworkInterfaceCard"
  }
}

resource "aws_security_group" "vpc_security_group" {
  name        = "Allow_HTTP_HTTPS_SSH"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.app_server_vpc.id
  
  dynamic "ingress" {
    for_each = var.security_group_ingress_ports
    content {
      from_port = ingress.value[0]
      to_port   = ingress.value[1]
      protocol  = "tcp"
      cidr_blocks = ingress.value[2]
    }
  }
  tags = {
    Name = "Allow_HTTP_HTTPS_SSH"
  }
}

#resource "aws_security_group_rule" "allow_ssh" {
#  type              = "ingress"
#  security_group_id = aws_security_group.vpc_security_group.id
#  cidr_blocks       = [ "0.0.0.0/0" ]
#  from_port         = 22
#  to_port           = 22
#  protocol          = "tcp"

#  dynamic "rules"{
#      for_each = each.rules
#      iterator = item
#      content {
#          cidr_blocks   = item.value.cidr_blocks
#          from_port     = item.value.from_port
#          to_port       = item.value.to_port   
#      }
#  }

#}

# resource "aws_security_group_rule" "allow_http" {
#  type              = "ingress"
#  security_group_id = aws_security_group.vpc_security_group.id
#  cidr_blocks       = [ aws_vpc.app_server_vpc.cidr_block ]
#  from_port         = 80
#  to_port           = 80
#  protocol          = "tcp"
# }

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
  network_interface_id  = aws_network_interface.app_server_nic.id
}

output "nic_id" {
  value = aws_network_interface.app_server_nic.id  
}
