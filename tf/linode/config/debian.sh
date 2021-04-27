#!/bin/bash
# configure Debian to use ansible

#apt-get update
apt-get update --allow-releaseinfo-change -y
apt-get install -y apt-transport-https python-apt

