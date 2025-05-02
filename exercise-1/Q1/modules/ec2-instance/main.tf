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

# Key Pair resource for accessing EC2 instance
resource "aws_key_pair" "app_server_instance_key" {
  key_name   = "${var.instance_name}_key"
  public_key = var.public_key    # Generating public key data through tls_private_key resource at root level
  #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjjRLbp1E33tjqSgvJdPy0d0O0skPuUuUHg98u4EDoYR5J1B5MLjiTao1AAtdngilUxHv7bXHbVSJCEbH9/6+Xs3gug8TThhuNfqcDt4r/SxKVshiaDd/iK1pFFo0YxXc47n0111zuanhKoDt/pUCrJ1h84lfoBEp7cUBnlrYa5vi1qApMOffHmlOwdMihJhIVXq+Y0br7rRMirAgfZtTn8Qeg3xnxRtrrFmKIdvvegnY86pTHCAnqiYWWytbKEazXopAJcR+kT6MHLEsco/w7ImP/3pu8yIqQYjjvD8ynyw17L663AIryuEPG4a623xLcKsR4GdTZl5mAwJpmnQBrIYfOhziW6EXNXCVUUbFfVPtMMtJa+xHqAmBYYKe/t71Afa0iB35liP+lYGJ+IsM980JbGAkQLQWPEr/iv67hhhMv8FlAsnVJciGwenWYDGZ0wR8vUrHrmAOdsnynFhUP9etuOn+s6iPAL40VzUrqRlUdX8XjmQg2Qr2a5zPbNV/x/+I7NIZk3RLQVFlHNSdOOsl6tNYYjJE+n4s0oejlBG+sxS53IJrHgCfmKIPkl9M0pS/BjTix3fg8OeFzmXKIuAO53dObvbD7WO2DH/cASpHLlyxfiH/sbiYmqqonKhEzJL3wb54FrwpETQ3P6utFXedcWLh0/lpN/HSF7d0E9Q== ubuntu@ip-172-31-46-136"
}

#EC2 configurations
resource "aws_instance" "app_server_instance" {
  ami           = var.ami
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
    #delete_on_termination = true
    device_index          = var.device_index
    network_interface_id  = var.network_interface_id
  }
}

output "ec2_instance_id" {
  value = aws_instance.app_server_instance.id
}