variable "aws_region" {
  description = "region"
  default     = "us-east-1"

}


# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Subnets
variable "subnet_public_1" {
  description = "CIDR block for the 1st public subnet"
  default     = "10.0.0.0/18"
}

variable "subnet_public_2" {
  description = "CIDR block for the 2st public subnet"
  default     = "10.0.64.0/18"
}

variable "subnet_private_1" {
  description = "CIDR block for the 1st private subnet"
  default     = "10.0.128.0/18"
}

variable "subnet_private_2" {
  description = "CIDR block for the 2st private subnet"
  default     = "10.0.192.0/18"
}

# Tags
variable "env" {
  description = "Enviroment name"
  default     = "PROD"

}

# Owner
variable "owner" {
  description = "Owner of the resources"
  default     = "IT"
}