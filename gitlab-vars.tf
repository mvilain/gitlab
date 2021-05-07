// gitlab-vars.tf -- spin up the gitlab aws and linode instances and define in DNS
//================================================== VARIABLES (in terraform.tfvars)
variable "aws_region" {
  description = "default region to setup all resources"
  type        = string
  default     = "us-east-2"
}
variable "aws_domain" {
  description = "DNS domain where aws instances are running"
  type        = string
  default     = "aws-vilain.com"
}

variable "aws_alma8_name" {
  description = "us-west-2 # ami-01a87a7d55032db2e"
  type        = list(string)
  default     = [ "SupportedImages AlmaLinux 8 x86_64*" ]
}
variable "aws_centos7_name" {
  description = "us-west-2 # ami-01e36b7901e884a10"
  type        = list(string)
  default     = [ "CentOS Linux 7 x86_64 HVM EBS ENA 2002_01*" ]
}
variable "aws_centos8_name" {
  description = "us-west-2 # ami-082a036ec7c372e4c"
  type        = list(string)
  default     = [ "SupportedImages CentOS Linux 8 x86_64 20210404-*" ]
}
variable "aws_debian9_name" {
  description = "us-west-2 # ami-0c18820215678d337"
  type        = list(string)
  default     = [ "SupportedImages debian-stretch-hvm-x86_64-gp2-2020 20210405*" ]
}
variable "aws_debian10_name" {
  description = "us-west-2 # ami-0a449b766e034390d"
  type        = list(string)
  default     = [ "SupportedImages debian-10-amd64 20210405*" ]
}
variable "aws_ubuntu16_name" {
  description = "us-west-2 # ami-0a65caa9c575c1c0c"
  type        = list(string)
  default     = [ "SupportedImages ubuntu-xenial-16.04-amd64-server*" ]
}
variable "aws_ubuntu18_name" {
  description = "us-west-2 # ami-00833850c832e03a2"
  type        = list(string)
  default     = [ "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20210325-*" ]
}
variable "aws_ubuntu20_name" {
  description = "us-west-2 # ami-06b3455df6cbbf3a2"
  type        = list(string)
  default     = [ "SupportedImages ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" ]
}


variable "linode_region" {
  description = "region where linode is running"
  type        = string
  default     =  "us-west"
}
variable "linode_domain" {
  description = "DNS domain where linodes are running"
  type        = string
  default     = "lin-vilain.com"
}
