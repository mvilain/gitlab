// aws-gitlab.tf -- define the gitlab aws instances
//================================================== VARIABLES (in gitlab-vars.tf)
######################################################################
# Configure the AWS Provider
terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    linode = {
      source  = "linode/linode"
      version = ">= 1.16.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "3.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
  }
}
