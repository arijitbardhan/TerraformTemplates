variable "instance_name" {
  type    = string
  default = "App_Server"
}

variable "subnet_id" {
  type = string
}

variable "private_ips" {
  type = list(string)
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "region" {
  type = string
}