// aws-vpc-security.tf -- define the gitlab aws vpc's network ACLs and security groups
// ================================================= SECURITY GROUPS
# apply network ACLs to VPC to restrict access to entire VPC 
# rather Security Groups which are per instance
# sadly network_acl_rules don't take descriptions
# resource "aws_network_acl" "gitlab_acl" {

# resource "aws_network_acl_rule" "gitlab_acl_egress" {
#   network_acl_id = aws_network_acl.gitlab_acl.id
#   rule_number    = 200
#   egress         = true
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 0
#   to_port        = 0
# }
# resource "aws_network_acl_rule" "gitlab_acl_http" {
#   network_acl_id = aws_network_acl.gitlab_acl.id
#   rule_number    = 100
#   egress         = false
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 0
#   to_port        = 0
# }

# resource "aws_network_acl_rule" "gitlab_acl_http" {
#   network_acl_id = aws_network_acl.gitlab_acl.id
#   rule_number    = 100
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 80
#   to_port        = 80
# }
# resource "aws_network_acl_rule" "gitlab_acl_https" {
#   network_acl_id = aws_network_acl.gitlab_acl.id
#   rule_number    = 110
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 443
#   to_port        = 443
# }
# resource "aws_network_acl_rule" "gitlab_acl_ssh_home" {
#   network_acl_id = aws_network_acl.gitlab_acl.id
#   rule_number    = 120
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "75.25.136.0/24"
#   from_port      = 22
#   to_port        = 22
# }
# resource "aws_network_acl_rule" "gitlab_acl_ssh_nord8524" {
#   network_acl_id = aws_network_acl.gitlab_acl.id
#   rule_number    = 130
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "192.145.118.0/24"
#   from_port      = 22
#   to_port        = 22
# }
# resource "aws_network_acl_rule" "gitlab_acl_ssh_leaseweb80" {
#   network_acl_id = aws_network_acl.gitlab_acl.id
#   rule_number    = 180
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "23.80.0.0/15"
#   from_port      = 22
#   to_port        = 22
# }
# resource "aws_network_acl_rule" "gitlab_acl_ssh_leaseweb82" {
#   network_acl_id = aws_network_acl.gitlab_acl.id
#   rule_number    = 182
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "23.82.0.0/16"
#   from_port      = 22
#   to_port        = 22
# }
# resource "aws_network_acl_rule" "gitlab_acl_ssh_leaseweb83" {
#   network_acl_id = aws_network_acl.gitlab_acl.id
#   rule_number    = 183
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "23.83.0.0/18"
#   from_port      = 22
#   to_port        = 22
# }


resource "aws_security_group" "gitlab_sg" {
  name        = "gitlab_sg"
  description = "Allow gitlab inbound traffic"
  vpc_id      = aws_vpc.gitlab_vpc.id

  tags = {
    Name      = "gitlab-sg",
    Terraform = "True"
  }
}
#
# gitlab's Let's Encrypt won't authenticate unless this is open
#
resource "aws_security_group_rule" "gitlab_sgr_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.gitlab_sg.id
}
#resource "aws_security_group_rule" "gitlab_sgr_all" {
#  type              = "ingress"
#  from_port         = 0
#  to_port           = 0
#  protocol          = "-1"
#  cidr_blocks       = [ "0.0.0.0/0" ]
#  security_group_id = aws_security_group.gitlab_sg.id
#}

resource "aws_security_group_rule" "gitlab_sgr_http" {
  type              = "ingress"
  description       = "gitlab http"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.gitlab_sg.id
}
resource "aws_security_group_rule" "gitlab_sgr_https" {
  type              = "ingress"
  description       = "gitlab https"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_att" {
  type              = "ingress"
  description       = "gitlab ssh att"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "75.25.136.0/24" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_mul_la" {
  type              = "ingress"
  description       = "gitlab ssh tor la"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "89.45.90.0/24" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_mul_sf" {
  type              = "ingress"
  description       = "gitlab ssh tor sf"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "199.116.112.0/21" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_mul_sj198" {
  type              = "ingress"
  description       = "gitlab ssh tor sj"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "198.54.134.0/24" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_mul_sj199" {
  type              = "ingress"
  description       = "gitlab ssh tor sj"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "199.116.118.0/24" ]
  security_group_id = aws_security_group.gitlab_sg.id
}



resource "aws_security_group_rule" "gitlab_sgr_ssh_mul_wa" {
  type              = "ingress"
  description       = "gitlab ssh tor Sea"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "192.252.208.0/20" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_tor_la" {
  type              = "ingress"
  description       = "gitlab ssh tor LA"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "37.120.147.0/24" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_tor_sf" {
  type              = "ingress"
  description       = "gitlab ssh tor SF"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "206.189.0.0/16" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_tor_nv" {
  type              = "ingress"
  description       = "gitlab ssh tor NV"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "185.242.5.0/24" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_tor_tx" {
  type              = "ingress"
  description       = "gitlab ssh tor TX"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "96.44.128.0/18" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_tor_ut" {
  type              = "ingress"
  description       = "gitlab ssh tor UT"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "209.95.32.0/19" ]
  security_group_id = aws_security_group.gitlab_sg.id
}

resource "aws_security_group_rule" "gitlab_sgr_ssh_tor_wa" {
  type              = "ingress"
  description       = "gitlab ssh tor WA"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "199.229.248.0/21" ]
  security_group_id = aws_security_group.gitlab_sg.id
}
