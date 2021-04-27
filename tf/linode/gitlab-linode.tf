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

######################################################################
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">= 1.16.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
  }
}

# use environment variables for access and secret key
provider "linode" {
}

//================================================== GENERATE KEYS AND SAVE

resource "tls_private_key" "linode_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "linode_pub_ssh_key" {
  content         = tls_private_key.linode_ssh_key.public_key_openssh
  filename        = "id_rsa.pub"
  file_permission = "0600"
}

resource "local_file" "linode_priv_ssh_key" {
  content         = tls_private_key.linode_ssh_key.private_key_pem
  filename        = "id_rsa"
  file_permission = "0600"
}

# there's really no need to know this password if using ssh -i private_key
resource "random_password" "linode_root_pass" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "local_file" "root_passwd" {
  content         = random_password.linode_root_pass.result
  filename        = "root-passwd"
  file_permission = "0600"
}

//================================================== INSTANCES
# inputs:
#  password - Linode root password                              [default: NONE ]
#  ssh_key  - Linode public ssh key for setting authorize_hosts [default: NONE ]
#  image    - Linode Image type used to create instance         [default: "linode/ubuntu18.04"]
#  region   - Linode region where instance will run             [default: "us-west"]
#  type     - Linode image size to use                          [default: "g6-nanode-1"]
#  label    - label used to create the instance and hostname    [default: "example"]
#  domain   - Linode-managed DNS domain used to assign host IP  [default: "example.com"]
module "lin_instance" {
  source   = "./modules/terraform-linode-instance"

#inputs:
  password = random_password.linode_root_pass.result
  ssh_key  = chomp(tls_private_key.linode_ssh_key.public_key_openssh)
  image    = "linode/centos7"
  script   = "centos7.sh"  # config/ is implied
#  region  = "us-east"
#  type    = "g6-standard-1"
  label    = "gitlab7"
  domain   = var.linode_domain
}
# outputs:
#  id
#  status
#  ip_address
#  private_ip_address
#  ipv6
#  ipv4
#  backups (enabled, schedule, day, window)
