#alma83...centos79...centos83...debian913...debian107...ubuntu1604...ubuntu1804...ubuntu2004...[done]
// generated from gitlab-aws-vars.j2 -- jinja2 template to provide gitlab aws instances
// [template for aws-list-gold-ami.py]
//================================================== VARIABLES
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

#========================================== AVAILABILTY ZONES
variable "aws_avz" {
  description = "us-east-2-zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

#========================================== alma83 2021-03-31T16:50:01.000Z
variable "aws_alma83_ami" {
  description = "us-east-2--AlmaLinux 8.3 (AlmaLinux8) (alma8) (alma 8.3) Minimal Install Golden AMI Template"
  type        = list(string)
  default     = [ "ami-01a87a7d55032db2e" ]
}
variable "aws_alma83_name" {
  description = "name for alma83 instance"
  type        = list(string)
  default     = [ "gitlab_alma83" ]
}
variable "aws_alma83_tag" {
  description = "tag for alma83 instance"
  type        = list(string)
  default     = [ "gitlab alma83" ]
}

#========================================== centos79 2020-03-09T21:54:47.000Z
variable "aws_centos79_ami" {
  description = "us-east-2--CentOS Linux 7 x86_64 HVM EBS ENA 2002_01"
  type        = list(string)
  default     = [ "ami-01e36b7901e884a10" ]
}
variable "aws_centos79_name" {
  description = "name for centos79 instance"
  type        = list(string)
  default     = [ "gitlab_centos79" ]
}
variable "aws_centos79_tag" {
  description = "tag for centos79 instance"
  type        = list(string)
  default     = [ "gitlab centos79" ]
}

#========================================== centos83 2021-04-04T15:49:32.000Z
variable "aws_centos83_ami" {
  description = "us-east-2--CentOS 8.3 (CentOS8) (cent8) (cent 8.3) Minimal Install Golden AMI Template"
  type        = list(string)
  default     = [ "ami-082a036ec7c372e4c" ]
}
variable "aws_centos83_name" {
  description = "name for centos83 instance"
  type        = list(string)
  default     = [ "gitlab_centos83" ]
}
variable "aws_centos83_tag" {
  description = "tag for centos83 instance"
  type        = list(string)
  default     = [ "gitlab centos83" ]
}

#========================================== debian913 2021-04-05T15:18:48.000Z
variable "aws_debian913_ami" {
  description = "us-east-2--Debian 9 (Debian Stretch) (debian9) Golden Image Template"
  type        = list(string)
  default     = [ "ami-0c18820215678d337" ]
}
variable "aws_debian913_name" {
  description = "name for debian913 instance"
  type        = list(string)
  default     = [ "gitlab_debian913" ]
}
variable "aws_debian913_tag" {
  description = "tag for debian913 instance"
  type        = list(string)
  default     = [ "gitlab debian913" ]
}

#========================================== debian107 2021-04-05T16:06:27.000Z
variable "aws_debian107_ami" {
  description = "us-east-2--Debian 10 (Debian Buster) (debian10) Debian 10 Golden Image Template"
  type        = list(string)
  default     = [ "ami-0a449b766e034390d" ]
}
variable "aws_debian107_name" {
  description = "name for debian107 instance"
  type        = list(string)
  default     = [ "gitlab_debian107" ]
}
variable "aws_debian107_tag" {
  description = "tag for debian107 instance"
  type        = list(string)
  default     = [ "gitlab debian107" ]
}

#========================================== ubuntu1604 2021-04-05T16:32:22.000Z
variable "aws_ubuntu1604_ami" {
  description = "us-east-2--Golden image (gold ami) template for Ubuntu Server 16.04 LTS (Ubuntu 16.04) (Ubuntu 16)"
  type        = list(string)
  default     = [ "ami-0a65caa9c575c1c0c" ]
}
variable "aws_ubuntu1604_name" {
  description = "name for ubuntu1604 instance"
  type        = list(string)
  default     = [ "gitlab_ubuntu1604" ]
}
variable "aws_ubuntu1604_tag" {
  description = "tag for ubuntu1604 instance"
  type        = list(string)
  default     = [ "gitlab ubuntu1604" ]
}

#========================================== ubuntu1804 2021-05-14T22:38:24.000Z
variable "aws_ubuntu1804_ami" {
  description = "us-east-2--Canonical, Ubuntu, 18.04 LTS, amd64 bionic image build on 2021-05-14"
  type        = list(string)
  default     = [ "ami-0baa47a966030510f" ]
}
variable "aws_ubuntu1804_name" {
  description = "name for ubuntu1804 instance"
  type        = list(string)
  default     = [ "gitlab_ubuntu1804" ]
}
variable "aws_ubuntu1804_tag" {
  description = "tag for ubuntu1804 instance"
  type        = list(string)
  default     = [ "gitlab ubuntu1804" ]
}

#========================================== ubuntu2004 2021-04-04T13:40:37.000Z
variable "aws_ubuntu2004_ami" {
  description = "us-east-2--Ubuntu Server 20.04 LTS (Ubuntu 20.04 LTS ) (Ubuntu 20) Focal Fossa"
  type        = list(string)
  default     = [ "ami-06b3455df6cbbf3a2" ]
}
variable "aws_ubuntu2004_name" {
  description = "name for ubuntu2004 instance"
  type        = list(string)
  default     = [ "gitlab_ubuntu2004" ]
}
variable "aws_ubuntu2004_tag" {
  description = "tag for ubuntu2004 instance"
  type        = list(string)
  default     = [ "gitlab ubuntu2004" ]
}


