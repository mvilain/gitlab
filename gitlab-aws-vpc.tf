// aws-gitlab-vpc.tf -- define the gitlab aws vpc
// ================================================= NETWORK+SUBNETS
## data "aws_vpc" "default" {
##   default    = true
## }
## data "aws_subnet_ids" "default" {
## vpc_id    = data.aws_vpc.default.id
## }
### data.aws_subnet_ids.default.ids lists region's default subnet ids

## data "aws_availability_zones" "available" {
##   state    = "available"
## }
### data.aws_availability_zones.available.names is list region's availability zones
### data.aws_availability_zones.available.zone_ids is list region's availability zone ids

# resource "aws_vpc" "gitlab_vpc" {
#   cidr_block           = "192.168.0.0/16"
#   enable_dns_hostnames = true
# }
#
# resource "aws_internet_gateway" "gitlab_gw" {
#   vpc_id = aws_vpc.gitlab_vpc.id
# }
# resource "aws_subnet" "gitlab_subnet" {
#   vpc_id                  = aws_vpc.gitlab_vpc.id
#   cidr_block              = "192.168.10.0/24"
#   map_public_ip_on_launch = true
#
#   depends_on = [aws_internet_gateway.gitlab_gw]
# }
