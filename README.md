# gitlab -- install and configure gitlab with load balancers

This project uses Vagrant to create three GitLab servers, a database server, and
a haproxy load balancer to cycle between the three servers.  All three servers
keep their database of users and repositories in the database server.

## Requirements

This project uses several roles that are in the transition to becoming 2.9's new Collections.  So that this project will run on 2.8, I've used these as roles rather than full-on collections which require 2.9.

- ansible-role-apache
- ansible-role-nginx
- ansible-role-nginx-config


## to do

- haproxy round-robin will not cycle if a host in the proxy list is down

won't respond to ping?  It's OK if node is up but http doesn't respond to heartbeat
