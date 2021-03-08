# gitlab -- Vagrant project to install and configure gitlab with load balancers

This project creates three GitLab servers, a database server, and a haproxy load balancer to cycle between the three servers.  All three servers keep their database of users and repositories in the database server.
