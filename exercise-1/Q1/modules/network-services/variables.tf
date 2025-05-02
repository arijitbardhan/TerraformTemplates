variable "region" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_block" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "map_public_ip_on_launch" {
  type = bool
}

variable "security_group_ingress_ports" {
  type = map(any)

  default = { "ingress1" = [80, 80, [ "10.0.0.0/16" ]],
              "ingress2" = [8080, 8080,[ "10.0.0.0/16" ]],
   	      "ingress3" = [443, 443, [ "10.0.0.0/16" ]],
  	      "ingress4" = [9000, 9000, [ "10.0.0.0/16" ]],
  	      "ingress5" = [2028, 2028, [ "10.0.0.0/16" ]] ,
  	      "ingress6" = [9090, 9090, [ "10.0.0.0/16" ]],
  	      "ingress7" = [22, 22, [ "10.0.0.0/16" ]],
  	      "ingress8" = [3306, 3306, [ "10.0.0.0/16" ]],
  	      "ingress9" = [5432, 5432, [ "10.0.0.0/16" ]],
  	      "ingress10" = [422, 422, [ "10.0.0.0/16" ]]
	    }
}

