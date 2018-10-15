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

variable "kms_key_id" {}

variable "dockerhub_username" {
  default = ""
}

variable "dockerhub_password" {
  default = ""
}

# Lambda autoscaling variables
variable "s3_bucket" {
  type = "string"
}

variable "s3_key" {
  type = "string"
}

variable "source_code_hash" {
  type    = "string"
  default = ""
}

variable "additional_user_data" {
  type    = "string"
  default = ""
}

variable "inline_host_policy" {
  type = "string"

  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

variable "additional_policy_attachments" {
  type    = "list"
  default = []
}
