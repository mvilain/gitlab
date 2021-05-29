// aws-gitlab-instances-debian.tf -- define the gitlab aws instances
//================================================== VARIABLES (in aws-vars.tf)
//================================================== PROVIDERS (in aws-providers.tf)
//================================================== S3 BACKEND (in aws-s3-backend.tf)
//================================================== GENERATE KEYS AND SAVE (in aws-keys.tf)

# manage ansible's inventory file because it will have different IPs each run
# also each instance has their own default AWS user
# (e.g. almalinux=ec2-user, centos=centos, debian=admin, ubuntu=ubuntu)
#resource "local_file" "inventory_aws_centos" {
#  content = <<-EOT
#  # this is overridden with every terraform run
#  [all:vars]
#  ansible_ssh_user=centos
#  ansible_ssh_private_key_file=./id_rsa
#  ansible_python_interpreter=/usr/libexec/platform-python
#
#  [all]
#  EOT
#  filename             = "inventory-centos"
#  directory_permission = "0755"
#  file_permission      = "0644"
#}
#
#resource "local_file" "inventory_aws_py3" {
#  content = <<-EOT
#  # this is overridden with every terraform run
#  [all:vars]
#  ansible_ssh_user=ubuntu
#  ansible_ssh_private_key_file=./id_rsa
#  ansible_python_interpreter=/usr/bin/python3
#
#  #ansible_ssh_user=admin
#
#  [all]
#  EOT
#  filename             = "inventory-py3"
#  directory_permission = "0755"
#  file_permission      = "0644"
#}

//================================================== NETWORK+SUBNETS+ACLs (aws-vpc.tf)
//================================================== SECURITY GROUPS (in aws-vpc-sg.tf)
//================================================== INSTANCES
## ./aws-list-gold-ami.py -t aws-list-gold-template.j2 > aws-vars.tf
# to generate vars below

# AWS uses hostnames in the form ip-xxx-xxx-xxx-xxx.REGION.compute.internal
# with cloud-init setup to disallow setting the hostname
# https://forums.aws.amazon.com/thread.jspa?threadID=165077
# https://aws.amazon.com/premiumsupport/knowledge-center/linux-static-hostname-rhel7-centos7/

module "gitlab_debian9" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_debian9_name  # defined in aws-vars.tf
  ami                    = var.aws_debian9_ami   # defined in aws-vars.tf
  domain                 = var.aws_domain          # defined in aws-vars.tf
  ansible_inventory      = "inventory-debian9"
  template               = "./aws-inv-debian9.j2"
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
  ansible_inventory      = "inventory-debian10"
  template               = "./aws-inv-debian10.j2"
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
  ansible_inventory      = "inventory-ubuntu16"
  template               = "./aws-inv-ubuntu16.j2"
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
  ansible_inventory      = "inventory-ubuntu18"
  template               = "./aws-inv-ubuntu18.j2"
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
  ansible_inventory      = "inventory-ubuntu20"
  template               = "./aws-inv-ubuntu20.j2"
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
