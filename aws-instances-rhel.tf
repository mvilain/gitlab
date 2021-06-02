// aws-gitlab-instances-centos.tf -- define the gitlab aws instances
//================================================== VARIABLES (in aws-vars.tf)
//================================================== PROVIDERS (in aws-providers.tf)
//================================================== S3 BACKEND (in aws-s3-backend.tf)
//================================================== GENERATE KEYS AND SAVE (in aws-keys.tf)
//================================================== NETWORK+SUBNETS+ACLs (aws-vpc.tf)
//================================================== SECURITY GROUPS (in aws-vpc-sg.tf)
//================================================== INSTANCES
# manage ansible's inventory file because it will have different IPs each run
# also each instance has their own default AWS user
## ./aws-list-gold-ami.py -t aws-list-gold-template.j2 > aws-vars.tf
# to generate vars below

# AWS uses hostnames in the form ip-xxx-xxx-xxx-xxx.REGION.compute.internal
# with cloud-init setup to disallow setting the hostname
# https://forums.aws.amazon.com/thread.jspa?threadID=165077
# https://aws.amazon.com/premiumsupport/knowledge-center/linux-static-hostname-rhel7-centos7/

module "gitlab_alma8" {
  source                 = "./terraform-modules/terraform-aws-ec2-instance"

  name                   = var.aws_alma8_name  # defined in aws-vars.tf
  ami                    = var.aws_alma8_ami   # defined in aws-vars.tf

  instance_type          = "t2.micro"
  instance_count         = 2
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
    os          = "alma8"
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

  instance_type          = "t2.micro"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
    os          = "centos7"
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

  instance_type          = "t2.micro"
  instance_count         = 1
  key_name               = aws_key_pair.gitlab_key.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.gitlab_sg.id ]
  subnet_id              = aws_subnet.gitlab_subnet.id
  tags = {
    Terraform   = "true"
    Environment = "gitlab"
    os          = "centos8"
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
