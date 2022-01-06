/*
variable "AWS_ACCESS_KEY" {
  type = string
  default = "ENTER YOUR ACCESS KEY VALUE"
}

variable "AWS_SECRET_KEY" {
  type = string
  default = "ENTER YOUR SECRET KEY VALUE"
}
*/

variable "AWS_REGION" {
  description = "AWS Region"
  type = string
  default = "eu-west-2"
}

variable "vpc_cidr_block" {
    description = "cidr blocks of VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnets_cidr_block" {
    description = "cidr blocks of public VPC subnets"
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr_block" {
    description = "cidr blocks of private VPC subnets"
    type = list(string)
    default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "AVAIL_ZONE" {
    description = "availability zones of the region"
    type = list(string)
    default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "ENVIRONMENT" {
  description = "The Environment i.e: Dev, Staging, Prod"
  type = string
  default = "DEV"
}

variable "PATH_TO_PUBLIC_KEY" {
    description = "Path to my local public key"
    type = string
    default = "/home/abdelrahman/.ssh/id_rsa.pub"
} 

variable "instance_type" {
  description = "The instance type to be launched"
  type = string
  default = "t2.micro"
}

variable "db_engine" {
    description = "The database engine"
    type = string
    default = "postgres"
}

variable "db_username" {
    description = "The database username"
    type = string
    default = "myusername"
}

variable "db_password" {
    description = "The database password"
    type = string
    sensitive = true
}


