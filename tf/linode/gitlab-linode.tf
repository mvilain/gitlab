// linode-gitlab.tf -- define the gitlab aws instances
//================================================== VARIABLES (in terraform.tfvars)
variable "aws_region" {
  description = "default region to setup all resources"
  type        = string
}
variable "aws_alma8_name" {
  description = "us-west-2 # ami-01a87a7d55032db2e"
  type        = list(string)
}
variable "aws_centos7_name" {
  description = "us-west-2 # ami-01e36b7901e884a10"
  type        = list(string)
}
variable "aws_centos8_name" {
  description = "us-west-2 # ami-082a036ec7c372e4c"
  type        = list(string)
}
variable "aws_debian9_name" {
  description = "us-west-2 # ami-0c18820215678d337"
  type        = list(string)
}
variable "aws_debian10_name" {
  description = "us-west-2 # ami-0a449b766e034390d"
  type        = list(string)
}
variable "aws_ubuntu16_name" {
  description = "us-west-2 # ami-0a65caa9c575c1c0c"
  type        = list(string)
}
variable "aws_ubuntu18_name" {
  description = "us-west-2 # ami-00833850c832e03a2"
  type        = list(string)
}
variable "aws_ubuntu20_name" {
  description = "us-west-2 # ami-06b3455df6cbbf3a2"
  type        = list(string)
}


variable "linode_region" {
  description = "region where linode is running"
  type        = string
}
variable "linode_domain" {
  description = "DNS domain where linode is running"
  type        = string
}
variable "linode_token" {
  description = "Linode access token"
  type        = string
}
variable "linode_root_pass" {
  description = "root password for linode"
  type        = string
}
variable "linode_ssh_key" {
  description = "ssh key for accessing linode"
  type    = list(string)
}

######################################################################
terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.16.0"
    }
  }
}

# use environment variables for access and secret key
provider "linode" {
#  token = "$LINODE_TOKEN"
}

#data "linode_region" "region" {
#  id = "us-east"
#}
# outputs
#   data.linode_region.region.country

//================================================== INSTANCES
# https://registry.terraform.io/modules/JamesWoolfenden/instance/linode/latest
#  image  - Linode Image type to use   - string   [default: "linode/ubuntu18.04"]
#  region - The Linode region to use   - string   [default: "us-west"]
#  type   - The image size type to use - string   [default: "g6-nanode-1"]
#  lable  - The label used to create the instance [default: "example"]
#   requires environment variable LINODE_TOKEN="xxxxx"
module "lin_instance" {
  source      = "./modules/terraform-linode-instance"

#inputs:
  image  = "linode/centos7"
#  region = "us-east"
#  type   = "g6-standard-1"
  label  = "gitlab7"

#outputs:
#  id
#  password
#  ssh
#  ip_address
}

resource "linode_domain" "lin-vilain" {
  type      = "master"
  domain    = "lin-vilain.com"
  soa_email = "encrypt@vilain.com"
}
# returns linode_domain.lin-vilain.id

resource "linode_domain_record" "gitlab7" {
  domain_id   = linode_domain.lin-vilain.id
  name        = "gitlab7"
  record_type = "A"
  target      = module.lin_instance.ip_address
}
