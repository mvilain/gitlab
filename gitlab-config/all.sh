#!/bin/bash
# configure all instances with base requirements

echo "...disabling CheckHostIP..."
sed -i.orig -e "s/#   CheckHostIP yes/CheckHostIP no/" /etc/ssh/ssh_config

