// aws-gitlab-instances-debian.tf -- define the gitlab aws instances
//================================================== VARIABLES (in aws-vars.tf)
//================================================== PROVIDERS (in aws-providers.tf)
//================================================== S3 BACKEND (in aws-s3-backend.tf)
//================================================== GENERATE KEYS AND SAVE (in aws-keys.tf)
//================================================== NETWORK+SUBNETS+ACLs (aws-vpc.tf)
//================================================== SECURITY GROUPS (in aws-vpc-sg.tf)
//================================================== INSTANCES
# manage ansible's inventory file because it will have different IPs each run
# also each instance has their own default AWS user
# (e.g. almalinux=ec2-user, centos=centos, debian=admin, ubuntu=ubuntu)

## ./aws-list-gold-ami.py -t aws-list-gold-template.j2 > aws-vars.tf
# to generate vars below

module "gitlab_debian9" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_debian9_name  # defined in aws-vars.tf
  ami                    = var.aws_debian9_ami   # defined in aws-vars.tf

  instance_type          = "t2.micro"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
    os          = "debian9"
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

  instance_type          = "t2.micro"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
    os          = "debian10"
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

  instance_type          = "t2.micro"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
    os          = "ubuntu16"
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

  instance_type          = "t2.micro"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
    os          = "ubuntu18"
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

  instance_type          = "t2.micro"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
    os          = "ubuntu20"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "preserve_hostname: false" >> /etc/cloud/cloud.cfg

    apt-get update -y
    apt-get install -y apt-transport-https python-apt
  EOF
}
