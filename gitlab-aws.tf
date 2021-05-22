// aws-gitlab.tf -- define the gitlab aws instances
//================================================== VARIABLES (in gitlab-vars.tf)
//================================================== PROVIDERS (in gitlab-providers.tf)

# use environment variables for access and secret key
provider "aws" {
  region    = var.aws_region
}

data "aws_region" "current" {}
# data.aws_region.name - The name of the selected region.
# data.aws_region.endpoint - The EC2 endpoint for the selected region.
# data.aws_region.description - region's description in this format: "Location (Region name)"

//================================================== S3 BACKEND (in gitlab-aws-s3-backend.tf)
//================================================== GENERATE KEYS AND SAVE
resource "tls_private_key" "aws_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "aws_pub_ssh_key" {
  content              = tls_private_key.aws_ssh_key.public_key_openssh
  filename             = "id_rsa.pub"
  directory_permission = "0755"
  file_permission      = "0600"
}

resource "local_file" "aws_priv_ssh_key" {
  content              = tls_private_key.aws_ssh_key.private_key_pem
  filename             = "id_rsa"
  directory_permission = "0755"
  file_permission      = "0600"
}

resource "aws_key_pair" "aws_gitlab_key" {
  key_name   = "aws_gitlab_key"
  public_key = tls_private_key.aws_ssh_key.public_key_openssh
}

# manage ansible's inventory file because it will have different IPs each run
# also each instance has their own default AWS user
# (e.g. almalinux=ec2-user, centos=centos, debian=admin, ubuntu=ubuntu)
resource "local_file" "inventory" {
  content = <<-EOT
  # this is overridden with every terraform run
  [all:vars]
  ansible_ssh_user=root
  ansible_ssh_private_key_file=./id_rsa
  ansible_python_interpreter=/usr/libexec/platform-python

  [all]
  EOT
  filename             = "inventory"
  directory_permission = "0755"
  file_permission      = "0644"
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
  filename             = "inventory_py3"
  directory_permission = "0755"
  file_permission      = "0644"
}

//================================================== NETWORK + SUBNETS (in gitlab-aws-vpc.tf)
//================================================== INSTANCES
## aws-list-gold-ami.py -t gitlab-aws-vars.j2 > gitlab-aws-vars.tf
# to generate vars below

# AlmaLinux 8.3 AMI
data "aws_ami" "alma8" {
  most_recent = true
  filter {
    name   = "name"
    values = var.aws_alma8_name
  }
  owners = ["679593333241"]
}
resource "aws_instance" "helloworlda8" {
  ami           = data.aws_ami.alma8.id # ami-01a87a7d55032db2e
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld-a8"
  }
}


# centos 7 AMI
data "aws_ami" "centos7" {
  most_recent = true
  filter {
    name   = "name"
    values = var.aws_centos7_name
  }
  owners = ["679593333241"]
}
resource "aws_instance" "helloworld7" {
  ami           = data.aws_ami.centos7.id # ami-01e36b7901e884a10
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld-c7"
  }
}

# centos 8.3 AMI
data "aws_ami" "centos8" {
  most_recent = true
  filter {
    name   = "name"
    values = var.aws_centos8_name
  }
  owners = ["679593333241"]
}
resource "aws_instance" "helloworldc8" {
  ami           = data.aws_ami.centos8.id # ami-082a036ec7c372e4c
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld-c8"
  }
}



# Debian 9 AMI
data "aws_ami" "debian9" {
  most_recent = true
  filter {
    name   = "name"
    values = var.aws_debian9_name
  }
  owners = ["679593333241"]
}
resource "aws_instance" "helloworld9" {
  ami           = data.aws_ami.debian9.id # ami-0c18820215678d337
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld-d9"
  }
}
# Debian 10 AMI
data "aws_ami" "debian10" {
  most_recent = true
  filter {
    name   = "name"
    values = var.aws_debian10_name
  }
  owners = ["679593333241"]
}
resource "aws_instance" "helloworld10" {
  ami           = data.aws_ami.debian10.id # ami-0a449b766e034390d
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld-d10"
  }
}



# Ubuntu 16 AMI
data "aws_ami" "ubuntu16" {
  most_recent = true
  filter {
    name   = "name"
    values = var.aws_ubuntu16_name
  }
  owners = ["679593333241"]
}
resource "aws_instance" "helloworld16" {
  ami           = data.aws_ami.ubuntu16.id # ami-0a65caa9c575c1c0c
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld-u16"
  }
}
# Ubuntu 18 AMI
data "aws_ami" "ubuntu18" {
  most_recent = true
  filter {
    name   = "name"
    values = var.aws_ubuntu18_name
  }
  owners = ["679593333241"]
}
resource "aws_instance" "helloworld18" {
  ami           = data.aws_ami.ubuntu18.id # ami-00833850c832e03a2
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld-u18"
  }
}
# Ubuntu 20 AMI
data "aws_ami" "ubuntu20" {
  most_recent = true
  filter {
    name   = "name"
    values = var.aws_ubuntu20_name
  }
  owners = ["679593333241"]
}
resource "aws_instance" "helloworld20" {
  ami           = data.aws_ami.ubuntu20.id # ami-06b3455df6cbbf3a2
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld-u20"
  }
}
