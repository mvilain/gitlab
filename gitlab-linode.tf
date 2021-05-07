// gitlab-linode.tf -- spin up the gitlab linode instances and define in DNS
//================================================== VARIABLES (in gitlab-vars.tf)
//================================================== PROVIDERS (in gitlab-providers.tf)

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

# manage ansible's inventory file because it will have different IPs each run
resource "local_file" "inventory" {
  content = <<-EOT
  # this is overridden with every terraform run
  [all:vars]
  ansible_ssh_user=root
  ansible_ssh_private_key_file=./id_rsa
  ansible_python_interpreter=/usr/libexec/platform-python
  
  [all]
  EOT
  filename        = "inventory"
  file_permission = "0644"
}

resource "local_file" "inventory_py3" {
  content = <<-EOT
  # this is overridden with every terraform run
  [all:vars]
  ansible_ssh_user=root
  ansible_ssh_private_key_file=./id_rsa
  ansible_python_interpreter=/usr/bin/python3

  [all]
  EOT
  filename        = "inventory_py3"
  file_permission = "0644"
}

//================================================== INSTANCES
# inputs:
#  password  - Linode root password                              [default: NONE ]
#  ssh_key   - Linode public ssh key for setting authorize_hosts [default: NONE ]
#  image     - Linode Image type used to create instance         [default: "linode/ubuntu18.04"]
#  region    - Linode region where instance will run             [default: "us-west"]
#  type      - Linode image size to use                          [default: "g6-nanode-1"]
#  label     - label used to create the instance and hostname    [default: "example"]
#  domain    - Linode-managed DNS domain used to assign host IP  [default: "example.com"]
#  inventory - ansible inventory file to append host             [default: inventory]
module "lin_gitlab7" {
  source   = "./terraform-modules/terraform-linode-instance"
  #
  password = random_password.linode_root_pass.result
  ssh_key  = chomp(tls_private_key.linode_ssh_key.public_key_openssh)
  domain   = var.linode_domain
  image    = "linode/centos7"
  type     = "g6-standard-2"
  script   = "centos7.sh"       # gitlab-config/ is implied
  label    = "gitlab7"
  inventory = "inventory"
}
# outputs:
#  id
#  status
#  ip_address
#  private_ip_address
#  ipv6
#  ipv4
#  backups (enabled, schedule, day, window)


module "lin_gitlab8" {
  source   = "./terraform-modules/terraform-linode-instance"
  #
  password = random_password.linode_root_pass.result
  ssh_key  = chomp(tls_private_key.linode_ssh_key.public_key_openssh)
  domain   = var.linode_domain
  image    = "linode/centos8"
  type     = "g6-standard-2"
  script   = "centos8.sh"
  label    = "gitlab8"
  inventory = "inventory"
}

# gitlab recommends running the app in 4GB machine
# nanodes are to small...worked OK in the 2GB linode
module "lin_gitlab9" {
  source   = "./terraform-modules/terraform-linode-instance"
  #
  password = random_password.linode_root_pass.result
  ssh_key  = chomp(tls_private_key.linode_ssh_key.public_key_openssh)
  domain   = var.linode_domain
  image    = "linode/debian9"
  type     = "g6-standard-2"
  script   = "debian.sh"
  label    = "gitlab9"
  inventory = "inventory_py3"
}

module "lin_gitlab10" {
  source   = "./terraform-modules/terraform-linode-instance"
  #
  password = random_password.linode_root_pass.result
  ssh_key  = chomp(tls_private_key.linode_ssh_key.public_key_openssh)
  domain   = var.linode_domain
  image    = "linode/debian10"
  type     = "g6-standard-2"
  script   = "debian.sh"
  label    = "gitlab10"
  inventory = "inventory_py3"
}

module "lin_gitlab16" {
  source   = "./terraform-modules/terraform-linode-instance"
  #
  password = random_password.linode_root_pass.result
  ssh_key  = chomp(tls_private_key.linode_ssh_key.public_key_openssh)
  domain   = var.linode_domain
  image    = "linode/ubuntu16.04lts"
  type     = "g6-standard-2"
  script   = "ubuntu.sh"
  label    = "gitlab16"
  inventory = "inventory_py3"
}
module "lin_gitlab18" {
  source   = "./terraform-modules/terraform-linode-instance"
  #
  password = random_password.linode_root_pass.result
  ssh_key  = chomp(tls_private_key.linode_ssh_key.public_key_openssh)
  domain   = var.linode_domain
  image    = "linode/ubuntu18.04"
  type     = "g6-standard-2"
  script   = "ubuntu.sh"
  label    = "gitlab18"
  inventory = "inventory_py3"
}
module "lin_gitlab20" {
  source   = "./terraform-modules/terraform-linode-instance"
  #
  password = random_password.linode_root_pass.result
  ssh_key  = chomp(tls_private_key.linode_ssh_key.public_key_openssh)
  domain   = var.linode_domain
  image    = "linode/ubuntu20.04"
  type     = "g6-standard-2"
  script   = "ubuntu.sh"
  label    = "gitlab20"
  inventory = "inventory_py3"
}