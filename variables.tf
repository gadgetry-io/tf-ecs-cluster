variable "projectname" {}

variable "private_security_group" {}

variable "private_subnets" {
  type = "list"
}

variable "public_security_group" {}

variable "public_subnets" {
  type = "list"
}

variable "cluster_name" {}

variable "provisioner_key_name" {
  default = "root"
}

variable "vpc_private_subnets" {
  type = "map"
}

variable "ecs_host_ami" {
  default = "ami-04351e12" # us-east-1 amzn-ami-2017.03.d-amazon-ecs-optimized
}

variable "ecs_host_size" {
  default = "m4.large"
}

variable "ecs_autoscale_min" {
  default = 3
}

variable "ecs_autoscale_max" {
  default = 5
}
