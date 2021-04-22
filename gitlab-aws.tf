// aws-gitlab.tf -- define the gitlab aws instances
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
# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# use environment variables for access and secret key
provider "aws" {
  region    = var.aws_region
}

data "aws_region" "current" {}
# data.aws_region.name - The name of the selected region.
# data.aws_region.endpoint - The EC2 endpoint for the selected region.
# data.aws_region.description - region's description in this format: "Location (Region name)".

//================================================== S3 ENCRYPTED BACKEND+LOCKS
resource "aws_s3_bucket" "tf-backend" {
  bucket = "mvilain-prod-tfstate-backend"
  acl    = "private"

#  lifecycle {
#    prevent_destroy = true
#  }
  
  versioning {
  enabled = true
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = "mvilain-prod-tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name       = "LockID"
    type       = "S"
  }
}

#terraform {
#  backend "local" {
#    path = "./terraform.tfstate"
#  }
#}
#terraform {
#    backend "s3" {
#    bucket         = "mvilain-prod-tfstate-backend"
#    key            = "global/s3/terraform.tfstate"
#    region         = "us-east-2"
#    dynamodb_table = "mvilain-prod-tfstate-locks"
#    encrypt        = true
#  }
#}
#terraform {
#  backend "s3" {
#    bucket         = "mvilain-prod-tfstate-backend"
#    key            = "vpc/terraform.tfstate"
#    region         = "us-east-2"
#    profile        = "tesera"
#    dynamodb_table = "mvilain-prod-tfstate-locks"
#    encrypt        = true
#    kms_key_id     = "arn:aws:kms:us-east-2:<account_id>:key/<key_id>"
#  }
#}
// ================================================== NETWORK + SUBNETS
# data "aws_vpc" "default" {
#   default    = true
# }
# data "aws_subnet_ids" "default" {
# vpc_id    = data.aws_vpc.default.id
# }
# data.aws_subnet_ids.default.ids lists region's default subnet ids

# data "aws_availability_zones" "available" {
#   state    = "available"
# }
# data.aws_availability_zones.available.names is lists region's availability zones
# data.aws_availability_zones.available.zone_ids is lists region's availability zone ids

# Create a VPC
# resource "aws_vpc" "example" {
#   cidr_block  = "192.168.10.0/24"
# }


//================================================== INSTANCES
# AlmaLinux 8.3 AMI
#aws ec2 describe-images --owners 'aws-marketplace'  \
#  --filters 'Name=product-code,Values=2pag55a9fkn96t01w4zg0hjzx' \
#  --output 'json'
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
# aws ec2 describe-images --owners 'aws-marketplace'  \
#   --filters 'Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce' \
#   --output 'json'
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
# aws ec2 describe-images --owners 'aws-marketplace'  \
#   --filters 'Name=product-code,Values=ef6kit54bxdxm5ec5h7921duf' \
#   --output 'json'
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
# aws ec2 describe-images --owners 'aws-marketplace'  \
#   --filters 'Name=product-code,Values=wa59nhjens2s3nbfqlcjxiyy' \
#   --output 'json'
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
# aws ec2 describe-images --owners 'aws-marketplace'  \
#   --filters 'Name=product-code,Values=a8to8juz0snuukwdxuz7x3ol8' \
#   --output 'json'
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
# aws ec2 describe-images --owners 'aws-marketplace'  \
#   --filters 'Name=product-code,Values=a77pfe5qy4y0x0ovr82l3q0jt' \
#   --output 'json'
#
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
# aws ec2 describe-images --owners 'aws-marketplace'  \
#   --filters 'Name=product-code,Values=3iplms73etrdhxdepv72l6ywj' \
#   --output 'json'
#
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
# aws ec2 describe-images --owners 'aws-marketplace'  \
#   --filters 'Name=product-code,Values=9rxhntdy981dz5t3gbzpdd60w' \
#   --output 'json'
#
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
