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

variable "public_key" {
  type = string
}

variable "ami" {
  type = string
}

variable "device_index" {
  type = number
}

variable "network_interface_id" {
  type = string
}