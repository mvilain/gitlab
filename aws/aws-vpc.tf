// aws-vpc.tf -- define the gitlab aws vpc
// ================================================= NETWORK+SUBNETS+ACLs
data "aws_vpc" "default" {
  default    = true
}

#data "aws_subnet_ids" "default" {
#vpc_id    = data.aws_vpc.default.id
#}
# data.aws_subnet_ids.default.ids lists region's default subnet ids

## data "aws_availability_zones" "available" {
##   state    = "available"
## }
### data.aws_availability_zones.available.names is list region's availability zones
### data.aws_availability_zones.available.zone_ids is list region's availability zone ids

resource "aws_vpc" "gitlab_vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name      = "gitlab-vpc",
    Terraform = "True"
  }
}

resource "aws_subnet" "gitlab_subnet" {
  vpc_id                  = aws_vpc.gitlab_vpc.id
  cidr_block              = "192.168.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.aws_avz[0]

  tags = {
    Name      = "gitlab-subnet",
    Terraform = "True"
  }
}

resource "aws_internet_gateway" "gitlab_gw" {
  vpc_id               = aws_vpc.gitlab_vpc.id

  tags = {
    Name = "gitlab-gw",
    Terraform = "True"
  }
}

resource "aws_route_table" "gitlab_rtb" {
  vpc_id = aws_vpc.gitlab_vpc.id
  route {
    cidr_block             = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gitlab_gw.id
  }

  tags = {
    Name      = "gitlab-rtb",
    Terraform = "True"
  }
}
resource "aws_route_table_association" "github_subnet_rtb" {
  subnet_id      = aws_subnet.gitlab_subnet.id
  route_table_id = aws_route_table.gitlab_rtb.id
}

## apply network ACLs to VPC to restrict access to entire VPC
## rather Security Groups which are per instance
## sadly network_acl_rules don't take descriptions
##
resource "aws_network_acl" "gitlab_acl" {
  vpc_id      = aws_vpc.gitlab_vpc.id
  subnet_ids  = [ aws_subnet.gitlab_subnet.id ]
  tags = {
    Name      = "gitlab-acl",
    Terraform = "True"
  }
}

## default network_acl settings
##
resource "aws_network_acl_rule" "gitlab_acl_egress" {
  network_acl_id = aws_network_acl.gitlab_acl.id
  rule_number    = 200
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
resource "aws_network_acl_rule" "gitlab_acl_http" {
  network_acl_id = aws_network_acl.gitlab_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
