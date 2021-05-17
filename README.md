# gitlab -- install and configure gitlab

This project uses Vagrant to create three GitLab servers, a database server, and
a haproxy load balancer to cycle between the three servers.  All three servers
keep their database of users and repositories in the database server.

## Requirements

- ansible-role-haproxy  --> haproxy

This role sets up haproxy without any monitoring page and doesn't automatically add servers to the configuration from an ansible group.  If you use the http health check provided, the default install of apache 2.4 will return 'Forbidden' which will fail.

Also, the haproxy process doesn't agregate logs in a separate file.

Instead of using this managed role as is, I combine it's features with my own module.

- [ansible-role-gitlab](https://github.com/geerlingguy/ansible-role-gitlab) was created in 2014 and is a bit old

it doesn't use the gitlab installation repos in

https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.{rpm|deb}.sh

from [Installing Gitlab](https://about.gitlab.com/install) which depends on the OS being installed.

The code from Guy's role has been enhanced and updated to run using CentOS (both 7 and AlamaLinux which is a straight port of CentOS 8), Debian 9 and 10, and Ubuntu 16.04 (deprecated in Gitlab 14), 18.04, and 20.04.

All the versions of the gitlab VM run setup and run the stand-alone http version of gitlab.  The https version requires the install to have a valid email address, FQDN for each VM, and access into the VM from the outside. Since this was tested with Vagrant on uVerse NAT network, I was unable to get ports open to allow for the Let's Encrypt code to validate the https certificate.  It still installs gitlab but the https certificate is invalid.

To work around this problem, instead of using Vagrant to run the project, use a Terraform model to deploy machines in AWS and the ansible playbook to deploy gitlab to the AWS machines.

- [terraform-linode-instance module](https://registry.terraform.io/modules/JamesWoolfenden/instance/linode/latest)

Initially, the module didn't work due to version incompatibilities.  I reported the issue and the author fixed it. Then I discovered I wanted to enhance the features of the module, so I forked it.

It now runs a pre-install script to configure nodes so they'll run ansible and adds the nodes to a pre-existing Linode-managed DNS domain.

If you define a DNS domain and assign it a SOA email address in linode's DNS service, update the the play-linode.yml playbook accordingly.  After terraform has created the nodes and inserted them into DNS domain, you can run the ansible playbook for the CentOS systems using the `inventory` file and the Debian/Ubuntu systems using the `inventory_py3` file.  These will correctly create the gitlab service on these hosts with https enabled.

- aws-list-gold-ami tool

The shell version of this tool exists as a testbed before coding the python version, which uses the AWS boto3 python library to access AWS services.

```
python3 -m venv venv
. venv/bin/activate
python3 -m pip install -r requirements.txt

Collecting boto3
  Downloading boto3-1.17.73-py2.py3-none-any.whl (131 kB)
     |████████████████████████████████| 131 kB 2.9 MB/s
Collecting s3transfer<0.5.0,>=0.4.0
  Using cached s3transfer-0.4.2-py2.py3-none-any.whl (79 kB)
Collecting jmespath<1.0.0,>=0.7.1
  Using cached jmespath-0.10.0-py2.py3-none-any.whl (24 kB)
Collecting botocore<1.21.0,>=1.20.73
  Using cached botocore-1.20.73-py2.py3-none-any.whl (7.5 MB)
Collecting urllib3<1.27,>=1.25.4
  Using cached urllib3-1.26.4-py2.py3-none-any.whl (153 kB)
Requirement already satisfied: python-dateutil<3.0.0,>=2.1 in /Library/Frameworks/Python.framework/Versions/3.8/lib/python3.8/site-packages (from botocore<1.21.0,>=1.20.73->boto3) (2.8.1)
Requirement already satisfied: six>=1.5 in /Library/Frameworks/Python.framework/Versions/3.8/lib/python3.8/site-packages (from python-dateutil<3.0.0,>=2.1->botocore<1.21.0,>=1.20.73->boto3) (1.16.0)
Installing collected packages: urllib3, jmespath, botocore, s3transfer, boto3
Successfully installed boto3-1.17.73 botocore-1.20.73 jmespath-0.10.0 s3transfer-0.4.2 urllib3-1.26.4
```



## TODO

- haproxy round-robin will not cycle if a host in the proxy list is down

won't respond to ping?  It's OK if node is up but http doesn't respond to heartbeat

- setup gitlab instances to point to a single postgresql server and use haproxy to load balance between them.
- `aws-list-gold-ami.sh`needs to be ported to python3.



## Appendix A

### Repo has submodules

Since this repo has submodules, you'll need to clone it and populate the submodules:

    git clone --recurse-submodules https://github.com/mvilain/gitlab.git


### adding submodule to git

This creates a HEADless snapshot of the submodule in the main repo.

    cd ~/gitlab/tf/linode/modules
    git submodule add git@github.com:mvilain/terraform-linode-instance.git

When you update the submodule and push it, the snapshot must be refreshed with the changes.

    git submodule update --remote
    git commit -a -m "submodule update"

### removing submodules from git

Here's how to remove submodules (from [How to delete a submodule](https://gist.github.com/myusuf3/7f645819ded92bda6677))

- Delete the relevant section from the .gitmodules file.
- Stage the .gitmodules changes git add .gitmodules
- Delete the relevant section from .git/config.
- Run `git rm --cached path_to_submodule` (no trailing slash).
- Run `rm -rf .git/modules/path_to_submodule` (no trailing slash).
- Commit `git commit -m "Removed submodule"`
- Delete the now untracked submodule files `rm -rf path_to_submodule`