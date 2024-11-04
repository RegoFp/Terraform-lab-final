variable "aws_region" {
    description = "region"
    default = "us-east-1"
  
}

#VPC
variable "vpc_cidr" {
    description = "Bloque CIDR para la VPC"
    default = "10.0.0.0/16"
}

variable "avaliability_zones" {
    description = "Las zonas de disponibilidad para las subredes"
    default = ["us-east-1a", "us-east-1b"]
  
}

#Subnets
variable "public_subnets" {
    description = "Lista de bloques CIDR para las subnets publicas"
    default = ["10.0.1.0/24", "10.0.2.0/24"]
  
}

variable "private_subnets" {
    description = "Lista de bloques CIDR para las subnets privadas"
    default = ["10.0.3.0/24", "10.0.4.0/24"]
  
}

variable "enable_nat_gateway" {
    description = "Variable para habilitar el NAT GW"
    default = true
}

variable "env" {
    description = "Enviroment name"
    default = "PROD"

}