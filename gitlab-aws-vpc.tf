// aws-gitlab-vpc.tf -- define the gitlab aws vpc
//================================================== VARIABLES (in gitlab-vars.tf)
//================================================== PROVIDERS (in gitlab-providers.tf)
//================================================== S3 BACKEND (in gitlab-aws-s3-backend.tf)
// ================================================= NETWORK+SUBNETS (in gitlab-aws-vpc.tf)
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
# resource "aws_vpc" "gitlab_vpc" {
#   cidr_block  = "192.168.10.0/24"
# }
