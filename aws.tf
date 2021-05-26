// aws-gitlab.tf -- define the gitlab aws instances
//================================================== VARIABLES (in aws-vars.tf)
//================================================== PROVIDERS (in aws-providers.tf)

# use environment variables for access and secret key
provider "aws" {
  region    = var.aws_region
}

data "aws_region" "current" {}
# data.aws_region.name - The name of the selected region.
# data.aws_region.endpoint - The EC2 endpoint for the selected region.
# data.aws_region.description - region's description in this format: "Location (Region name)"

//================================================== S3 BACKEND (in aws-s3-backend.tf)
//================================================== GENERATE KEYS AND SAVE
resource "tls_private_key" "gitlab_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "gitlab_pub_ssh_key" {
  content              = tls_private_key.gitlab_ssh_key.public_key_openssh
  filename             = "id_rsa.pub"
  directory_permission = "0755"
  file_permission      = "0600"
}

resource "local_file" "gitlab_priv_ssh_key" {
  content              = tls_private_key.gitlab_ssh_key.private_key_pem
  filename             = "id_rsa"
  directory_permission = "0755"
  file_permission      = "0600"
}

resource "aws_key_pair" "gitlab_key" {
  key_name   = "gitlab_key"
  public_key = chomp(tls_private_key.gitlab_ssh_key.public_key_openssh)
}
#id - The key pair name.
#arn - The key pair ARN.
#key_name - The key pair name.
#key_pair_id - The key pair ID.
#fingerprint - The MD5 public key fingerprint as specified in section 4 of RFC 4716.
#tags_all

# manage ansible's inventory file because it will have different IPs each run
# also each instance has their own default AWS user
# (e.g. almalinux=ec2-user, centos=centos, debian=admin, ubuntu=ubuntu)
resource "local_file" "inventory_aws_centos" {
  content = <<-EOT
  # this is overridden with every terraform run
  [all:vars]
  ansible_ssh_user=centos
  ansible_ssh_private_key_file=./id_rsa
  ansible_python_interpreter=/usr/libexec/platform-python

  [all]
  EOT
  filename             = "inventory-centos"
  directory_permission = "0755"
  file_permission      = "0644"
}

resource "local_file" "inventory_aws_py3" {
  content = <<-EOT
  # this is overridden with every terraform run
  [all:vars]
  ansible_ssh_user=ubuntu
  ansible_ssh_private_key_file=./id_rsa
  ansible_python_interpreter=/usr/bin/python3

  #ansible_ssh_user=admin

  [all]
  EOT
  filename             = "inventory-py3"
  directory_permission = "0755"
  file_permission      = "0644"
}

//================================================== NETWORK+SUBNETS+ACLs (aws-vpc.tf)
//================================================== SECURITY GROUPS (in aws-vpc-sg.tf)
//================================================== INSTANCES
## ./aws-list-gold-ami.py -t aws-vars.j2 > aws-vars.tf
# to generate vars below

# AWS uses hostnames in the form ip-xxx-xxx-xxx-xxx.REGION.compute.internal
# with cloud-init setup to disallow setting the hostname
# https://forums.aws.amazon.com/thread.jspa?threadID=165077
# https://aws.amazon.com/premiumsupport/knowledge-center/linux-static-hostname-rhel7-centos7/

module "gitlab_alma8" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_alma8_name  # defined in aws-vars.tf
  ami                    = var.aws_alma8_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain      # defined in aws-vars.tf
  inventory              = "inventory-centos"
  user                   = "ec2-user"

  instance_type          = "t2.medium"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: false" >> /etc/cloud/cloud.cfg

    dnf install -y epel-release
    dnf config-manager --set-enabled powertools
    dnf makecache
    dnf install -y ansible
    alternatives --set python /usr/bin/python3
  EOF
}

module "gitlab_centos7" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_centos7_name  # defined in aws-vars.tf
  ami                    = var.aws_centos7_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain        # defined in aws-vars.tf
  inventory              = "inventory-centos"
  user                   = "centos"

  instance_type          = "t2.medium"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: false" >> /etc/cloud/cloud.cfg

    yum install -y epel-release
    yum install -y ansible
#    yum install -y python3 libselinux-python3 git
    alternatives --set python /usr/bin/python
  EOF
}

module "gitlab_centos8" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_centos8_name  # defined in aws-vars.tf
  ami                    = var.aws_centos8_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain        # defined in aws-vars.tf
  inventory              = "inventory-centos"
  user                   = "centos"

  instance_type          = "t2.medium"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: false" >> /etc/cloud/cloud.cfg

    dnf install -y epel-release
    dnf config-manager --set-enabled powertools
    dnf makecache
    dnf install -y ansible
    alternatives --set python /usr/bin/python3
  EOF
}



module "gitlab_debian9" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_debian9_name  # defined in aws-vars.tf
  ami                    = var.aws_debian9_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain          # defined in aws-vars.tf
  inventory              = "inventory-py3"
  user                   = "admin"

  instance_type          = "t2.medium"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: false" >> /etc/cloud/cloud.cfg

    apt-get update -y
    apt-get install -y apt-transport-https python-apt
  EOF
}

module "gitlab_debian10" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_debian10_name  # defined in aws-vars.tf
  ami                    = var.aws_debian10_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain         # defined in aws-vars.tf
  inventory              = "inventory-py3"
  user                   = "admin"

  instance_type          = "t2.medium"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: false" >> /etc/cloud/cloud.cfg

    apt-get update -y
    apt-get install -y apt-transport-https python-apt
  EOF
}



module "gitlab_ubuntu16" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_ubuntu16_name  # defined in aws-vars.tf
  ami                    = var.aws_ubuntu16_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain         # defined in aws-vars.tf
  inventory              = "inventory-py3"
  user                   = "ubuntu"

  instance_type          = "t2.medium"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: false" >> /etc/cloud/cloud.cfg

    apt-get update -y
    apt-get install -y apt-transport-https python-apt
  EOF
}

module "gitlab_ubuntu18" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_ubuntu18_name  # defined in aws-vars.tf
  ami                    = var.aws_ubuntu18_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain         # defined in aws-vars.tf
  inventory              = "inventory-py3"
  user                   = "ubuntu"

  instance_type          = "t2.medium"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: false" >> /etc/cloud/cloud.cfg

    apt-get update -y
    apt-get install -y apt-transport-https python-apt
  EOF
}

module "gitlab_ubuntu20" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_ubuntu20_name  # defined in aws-vars.tf
  ami                    = var.aws_ubuntu20_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain         # defined in aws-vars.tf
  inventory              = "inventory-py3"
  user                   = "ubuntu"

  instance_type          = "t2.medium"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: false" >> /etc/cloud/cloud.cfg

    apt-get update -y
    apt-get install -y apt-transport-https python-apt
  EOF
}
