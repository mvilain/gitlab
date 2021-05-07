#!/bin/bash
#
# uses aws cli to crawl through aws' marketplace and list instances for
# - centos7
# - almalinux (centos8 replacement)
# - debian9
# - debian10
# - ubuntu16.04
# - ubuntu18.04
# - ubuntu20.04
#
# uses region defined in awscli's credentials

# almalinux AMI (centos8 replacement)
aws ec2 describe-images --owners 'aws-marketplace'  \
  --filters 'Name=product-code,Values=2pag55a9fkn96t01w4zg0hjzx' \
  --output 'json' --no-cli-pager


# centos 7 AMI
aws ec2 describe-images --owners 'aws-marketplace'  \
  --filters 'Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce' \
  --output 'json' --no-cli-pager

# centos 8.3 AMI
aws ec2 describe-images --owners 'aws-marketplace'  \
  --filters 'Name=product-code,Values=ef6kit54bxdxm5ec5h7921duf' \
  --output 'json' --no-cli-pager


# Debian 9 AMI
aws ec2 describe-images --owners 'aws-marketplace'  \
  --filters 'Name=product-code,Values=wa59nhjens2s3nbfqlcjxiyy' \
  --output 'json' --no-cli-pager

# Debian 10 AMI
aws ec2 describe-images --owners 'aws-marketplace'  \
  --filters 'Name=product-code,Values=a8to8juz0snuukwdxuz7x3ol8' \
  --output 'json' --no-cli-pager


# Ubuntu 16 AMI
aws ec2 describe-images --owners 'aws-marketplace'  \
  --filters 'Name=product-code,Values=a77pfe5qy4y0x0ovr82l3q0jt' \
  --output 'json' --no-cli-pager

# Ubuntu 18 AMI
aws ec2 describe-images --owners 'aws-marketplace'  \
  --filters 'Name=product-code,Values=3iplms73etrdhxdepv72l6ywj' \
  --output 'json' --no-cli-pager

# Ubuntu 20 AMI
aws ec2 describe-images --owners 'aws-marketplace'  \
  --filters 'Name=product-code,Values=9rxhntdy981dz5t3gbzpdd60w' \
  --output 'json' --no-cli-pager
