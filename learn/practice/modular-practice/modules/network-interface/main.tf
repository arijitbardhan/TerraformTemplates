provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_network_interface" "app_server_nic" {
  subnet_id   = var.subnet_id
  private_ips = var.private_ips
  
  tags = {
    Name = "${var.instance_name}_NetworkInterfaceCard"
  }
}