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
}

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

# domain already created and won't be managed
data "linode_domain" "lin-vilain" {
  domain    = "lin-vilain.com"
}
# output
#  id - The unique ID of this Domain.
#  domain - The domain this Domain represents. These must be unique in our system; you cannot have two Domains representing the same domain
#  type - If this Domain represents the authoritative source of information for the domain it describes, or if it is a read-only copy of a master (also called a slave)
#  group - The group this Domain belongs to.
#  status - Used to control whether this Domain is currently being rendered.
#  description - A description for this Domain.
#  master_ips - The IP addresses representing the master DNS for this Domain.
#  axfr_ips - The list of IPs that may perform a zone transfer for this Domain.
#  ttl_sec - 'Time to Live'-the amount of time in seconds that this Domain's records may be cached by resolvers or other domain servers.
#  retry_sec - The interval, in seconds, at which a failed refresh should be retried.
#  expire_sec - The amount of time in seconds that may pass before this Domain is no longer authoritative.
#  refresh_sec - The amount of time in seconds before this Domain should be refreshed.
#  soa_email - Start of Authority email address.
#  tags - An array of tags applied to this object.

resource "linode_domain_record" "gitlab7" {
  domain_id   = data.linode_domain.lin-vilain.id
  name        = "gitlab7"
  record_type = "A"
  target      = module.lin_instance.ip_address
}
