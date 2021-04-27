# gitlab -- install and configure gitlab with load balancers

This project uses Vagrant to create three GitLab servers, a database server, and
a haproxy load balancer to cycle between the three servers.  All three servers
keep their database of users and repositories in the database server.

## Requirements

- ansible-role-haproxy  --> haproxy

This role sets up haproxy without any monitoring page and doesn't automatically add servers to the configuration from an ansible group.  If you use the http health check provided, the default install of apache 2.4 will return 'Forbidden' which will fail.

Also, the haproxy process doesn't agregate logs in a separate file.

Instead of using this managed role as is, I combine it's features with my own module.


- [https://github.com/geerlingguy/ansible-role-gitlab](ansible-role-gitlab) was created in 2014 and is a bit old

it doesn't use the gitlab installation repos in

https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.{rpm|deb}.sh

from [https://about.gitlab.com/install](Installing Gitlab) which depends on the OS being installed.

The code from Guy's role has been enhanced and updated to run using CentOS (both 7 and AlamaLinux which is a straight port of CentOS 8), Debian 9 and 10, and Ubuntu 16.04 (deprecated in Gitlab 14), 18.04, and 20.04.

All the versions of the gitlab VM run setup and run the stand-alone http version of gitlab.  The https version requires the install to have a valid email address, FQDN for each VM, and access into the VM from the outside. Since this was tested with Vagrant on uVerse NAT network, I was unable to get ports open to allow for the Let's Encrypt code to validate the https certificate.  It still installs gitlab but the https certificate is invalid.

To work around this problem, instead of using Vagrant to run the project, use a Terraform model to deploy machines in AWS and the ansible playbook to deploy gitlab to the AWS machines.

## to do

- haproxy round-robin will not cycle if a host in the proxy list is down

won't respond to ping?  It's OK if node is up but http doesn't respond to heartbeat



## Appendix A

### adding submodule to git

- cd ~/gitlab/tf/linode/modules
- git submodule add git@github.com:mvilain/terraform-linode-instance.git
- git submodule update --init --recursive

### removing submodules from git

Here's how to remove submodules:

- Delete the relevant section from the .gitmodules file.
- Stage the .gitmodules changes git add .gitmodules
- Delete the relevant section from .git/config.
- Run git rm --cached path_to_submodule (no trailing slash).
- Run rm -rf .git/modules/path_to_submodule (no trailing slash).
- Commit git commit -m "Removed submodule "
- Delete the now untracked submodule files rm -rf path_to_submodule

from [https://gist.github.com/myusuf3/7f645819ded92bda6677](How to delete a submodule)
