# gitlab -- install and configure gitlab with load balancers

This project uses Vagrant to create three GitLab servers, a database server, and
a haproxy load balancer to cycle between the three servers.  All three servers
keep their database of users and repositories in the database server.

## Requirements

This project uses several roles that are in the transition to becoming 2.9's new Collections.  So that this project will run on 2.8, I've used these as roles rather than full-on collections which require 2.9.

- ansible-role-apache
- ansible-role-nginx

These modules work well in creating default setups for apache and nginx.

- ansible-role-haproxy  --> haproxy

This role sets up haproxy without any monitoring page and doesn't automatically add servers to the configuration from an ansible group.  If you use the http health check provided, the default install of apache 2.4 will return 'Forbidden' which will fail.

Also, the haproxy process doesn't agregate logs in a separate file.

Instead of using this role as is, combine the features of it with my own module.


## to do

- haproxy round-robin will not cycle if a host in the proxy list is down

won't respond to ping?  It's OK if node is up but http doesn't respond to heartbeat
