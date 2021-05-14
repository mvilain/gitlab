#!/bin/bash
# 202105.13MeV
# uses aws cli to crawl through aws' marketplace and list instances for
# - centos7
# - almalinux (centos8 replacement)
# - debian9
# - debian10
# - ubuntu16.04
# - ubuntu18.04
# - ubuntu20.04
#
# awscli and jq are required to run this tool
# uses region defined in awscli's credentials if not specified in $1
# credentials file must be present with the region and keys
#

PROG=$(basename $0)
OPT_R="false"

CONFIG=~/.aws/config
[ ! -e $CONFIG ]&& echo "$PROG -- aws cli config file $CONFIG not found" && exit 1
REGION=$(awk '/^region /{print $3}' $CONFIG)    # chose default REGION from config

TMPFILE=$(mktemp /tmp/${PROG}.XXXXXX)
aws ec2 describe-regions --no-paginate --output text | awk '{ print $4 }' > $TMPFILE


usage () {
        cat <<USAGE

        $PROG -hr <REGION>

        display the AMI strings for Gitlab-supported virtual machines

        OPTIONS
        <REGION>     AWS region to scan [default: $REGION]
        -r           lists the valid AWS regions

USAGE
  [ -e $TMPFILE ] && rm $TMPFILE
  exit $1
}

trap ctrl_c INT # trap ctrl-c and call ctrl_c()

function ctrl_c() {
  echo "$PROG -- aborted"
  rm $TMPFILE
  exit 2
}


while getopts ":hr" OPT; do
  case $OPT in
  h )
    usage
    ;;
  r )
    echo "$PROG -- valid AWS for regions:"
    echo ""
    fmt -72 $TMPFILE
    rm $TMPFILE
    exit
    ;;
  \? )
    echo "$PROG -- invalid option: -$OPTARG" 1>&2
    usage 1
    ;;
  esac
done

shift $((OPTIND-1))     # shift points arg list to 1st non-argument
[ "$1" != "" ] && REGION=$1

# check if REGION is valid
if [ "x$REGION" != "x" ]; then
  lc_region=$(grep -s -i "^${REGION}$" $TMPFILE)  # TMPFILE always lcase regions
  # grep returns $?=0 if OK, which is the opposite of most languages
  if [ $? -ne 0 ]; then
    echo "$PROG -- invalid region \"$REGION\"...use -r to list valid regions"
    usage 1
  fi
  REGION=$lc_region
fi

for distro in $(cat <<-PRODCODES | awk '{print $2}'
    almalinux   2pag55a9fkn96t01w4zg0hjzx
    centos7.9   aw0evgkw8e5c1q413zgy5pjce
    centos8.3   ef6kit54bxdxm5ec5h7921duf
    debian9.13  wa59nhjens2s3nbfqlcjxiyy
    debian10.7  a8to8juz0snuukwdxuz7x3ol8
    ubuntu16.04 a77pfe5qy4y0x0ovr82l3q0jt
    ubuntu18.04 3iplms73etrdhxdepv72l6ywj
    ubuntu20.04 9rxhntdy981dz5t3gbzpdd60w
PRODCODES
); do
  # for some reason awscli won't pipe but it will redirect ouput
  aws ec2 describe-images --owners 'aws-marketplace' \
    --filters "Name=product-code,Values=$distro" \
    --output 'json' --no-cli-pager --region $REGION > $TMPFILE
  jq -r ".Images[] | .CreationDate, .ImageId, .ImageLocation" $TMPFILE
  echo ""
done
rm $TMPFILE
exit
