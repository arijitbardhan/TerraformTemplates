variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "App_Server"
}

variable "root_block_device_delete_on_termination" {
  type = bool
}

variable "root_block_device_encrypted" {
  type = bool
}

variable "root_block_device_volume_size" {
  type = number
}

variable "root_block_device_volume_type" {
  type = string
}

variable "ec2_network_interface_device_index" {
  type = number
}

variable "instance_storage_size" {
  type = number
}

variable "instance_storage_availability_zone" {
  type    = string
  default = "ap-south-1a"
}

variable "ebs_attachment_to_ec2_device_name" {
  type    = string
  default = "/dev/sdh"
}

variable "app_server_vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "app_server_subnet_public_ip" {
  type = bool
}

variable "security_group_ingress_ports" {
  type = map(any)
  default = { "ingress1" = [80, 80, [ "0.0.0.0/0" ]],
              "ingress2" = [22, 22,[ "0.0.0.0/0" ]],
              "ingress3" = [443, 443, [ "0.0.0.0/0" ]]
            }  
}