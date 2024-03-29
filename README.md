# gitlab -- install and configure gitlab

This project uses Vagrant to create three GitLab servers, a database server, and
a haproxy load balancer to cycle between the three servers.  All three servers
keep their database of users and repositories in the database server.

## Requirements

### ansible-role-haproxy  --> haproxy

This role sets up haproxy without any monitoring page and doesn't automatically add servers to 
the configuration from an ansible group.  If you use the http health check provided, the default 
install of apache 2.4 will return 'Forbidden' which will fail.

Also, the haproxy process doesn't agregate logs in a separate file.

Instead of using this managed role as is, I combine it's features with my own module.

### [ansible-role-gitlab](https://github.com/geerlingguy/ansible-role-gitlab) 

This ansible role was created in 2014 and is a bit old. It doesn't use the gitlab installation scripts

- https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh
- https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh

from [Installing Gitlab](https://about.gitlab.com/install) which depends on the OS being installed.

The code from Guy's role has been enhanced and updated to run using CentOS (both 7 and AlamaLinux which 
is a straight port of CentOS 8), Debian 9, 10, 11, and Ubuntu 18.04, 20.04, and 22.04.

All the versions of the gitlab VM run setup and run the stand-alone http version of gitlab.  
The https version requires the install to have a valid email address, FQDN for each VM, and 
access into the VM from the outside. Since this was tested with Vagrant on uVerse NAT network, 
I was unable to get ports open to allow for the Let's Encrypt code to validate the https certificate.  
It still installs gitlab but the https certificate is invalid.

To work around this problem, instead of using Vagrant to run the project, use a Terraform model to 
deploy machines in AWS and the ansible playbook to deploy gitlab to the AWS machines.

### aws-list-gold-ami tool

The shell version of this tool exists as a testbed before coding the python version, which uses 
the AWS boto3 python library to access AWS services.  It requires specific python libraries to run.  
You can run the script with in a python virtual environment. It will install the libraries in the 
virtual environment directory without impacting the system.

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

$ ./aws-list-gold-ami.py -h
usage: aws-list-gold-ami.py [-h] [-l] [-t TEMPLATE] [-v] [REGION]

display the AMI strings for Gitlab-supported virtual machines

positional arguments:
  REGION                region to use for AMI images [default: XXXXXXX]

optional arguments:
  -h, --help            show this help message and exit
  -l, --list            List the valid AWS regions
  -t TEMPLATE, --template TEMPLATE
                        JINJA2 template file to fill in with AMI info
  -v, --verbose         show all the AMI image info
```

This tool queries the AWS Marketplace for the latest gold AMIs for 

- Amazon Linux 2
- CentOS 7
- CentOS 8 + AlmaLinux 8.3
- Debian 9
- Debian 10
- Ubuntu 18.04
- Ubuntu 20.04

It displays the instance information for each distro. In some cases, there may be multiple copies, 
each with a separate creation date. The tool selects the most current AMI to display.  

It requires the files `~/.aws/{credentials,config}` be present in order to run. These files are also 
used by the aws-cli tool.

In addition, it can create a terraform vars file from a jinja2 template.  Currently, the template 
creates variables for use with the Terraform Modules.

```
// generated from gitlab-aws-vars.j2 -- jinja2 template to provide gitlab aws instances
// [template for aws-list-gold-ami.py]
//================================================== VARIABLES
variable "aws_region" {
  description = "default region to setup all resources"
  type        = string
  default     = "{{ region }}"
}
variable "aws_domain" {
  description = "DNS domain where aws instances are running"
  type        = string
  default     = "aws-vilain.com"
}

#========================================== AVAILABILTY ZONES
variable "aws_avz" {
  description = "{{ region }}-zones"
  type        = list(string)
  default     = [ 
  {%- for avz in avzs -%}"{{- avz.ZoneName }}{{ '", ' if not loop.last else '"' }}{% endfor -%} ]
}

{% for image in images -%}
#========================================== {{ image.distro }} {{ image.CreationDate }}
variable "aws_{{ image.distro }}_ami" {
  description = "{{ image.region }}--{{ image.Description }}"
  type        = list(string)
  default     = [ "{{ image.ImageID }}" ]
}
variable "aws_{{ image.distro }}_name" {
  description = "name for {{ image.distro }} instance"
  type        = list(string)
  default     = [ "gitlab_{{ image.distro }}" ]
}

{% endfor %}
```

### AWS inventory generation

The [link to AWS version](https://aws.amazon.com/blogs/apn/getting-started-with-ansible-and-dynamic-amazon-ec2-inventory-management/) 
of this script is no longer valid.  The [ansible plugin](https://raw.githubusercontent.com/ansible/ansible/stable-2.9/contrib/inventory/ec2.py) 
and it's [corresponding ini file](https://raw.githubusercontent.com/ansible/ansible/stable-2.9/contrib/inventory/ec2.ini) are maintained code. 
Ansible also has some [old documentation](https://web.archive.org/web/20170630221334/http://docs.ansible.com/ansible/intro_dynamic_inventory.html#example-aws-ec2-external-inventory-script) 
on how to setup the inventory file and playbooks using this script.

The [updated fork](https://raw.githubusercontent.com/vshn/ansible-dynamic-inventory-ec2/master/ec2.py) that 
allows for a sorted list. But it has drawbacks:

- able to collect info on running instances, but it's SLOW
- requires ansible 2.9 and uses old boto library to connect to AWS
- generates ansible hostvars and groupvars with "-" which are invalid
- could not get it to work solely as an inventory source from command-line or playbook
- can't differentiate between 4 different OS' and two different python interpeters

This points to a custom pythons script that collects the running instance's info and populates a inventory file 
from a template, similar to the python script to scan for the GOLD AMIs.


To use this script, install the required python modules either under a virtual environment or directly onto your 
system.  Then define the following along with the AWS authentication keys:

```bash
python3 -m venv venv
. venv/bin/activate
python3 -m pip install -r requirements.txt


# export these variables with your keys
export AWS_ACCESS_KEY_ID='YOUR_AWS_API_KEY'
export AWS_SECRET_ACCESS_KEY='YOUR_AWS_API_SECRET_KEY'
# OR
aws configure
#[answer the questions and supply the keys and default region]
```

When running EC2 instances exist, the ec2.py script will run the AWS `describe_instances` query for running 
instances are report back a variety of critera that can be used in the `inventory_aws` file.


### Linode inventory generation

The Linode list is available from 

    curl -s https://api.linode.com/v4/images | jq ".data[]|.id" | sed -e 's/"//g'

The full list of regions is available from

    curl -s https://api.linode.com/v4/regions |jq ".data[]|.id" | sed -e 's/"//g'

The full list of types is available from

    curl -s https://api.linode.com/v4/linode/types | jq ".data[] | .id" | sed -e 's/"//g'



### Terraform Modules

#### [forked terraform-linode-instance module](https://github.com/mvilain/terraform-linode-instance)

formed from https://registry.terraform.io/modules/JamesWoolfenden/instance/linode/latest

Initially, the original module didn't work due to version incompatibilities.  I reported the issue and the 
author fixed it. Then I discovered I wanted to enhance the features of the module, so I forked it.

It now runs a pre-install script to configure nodes so they'll run ansible and adds the nodes to a pre-existing 
Linode-managed DNS domain.

If you define a DNS domain and assign it a SOA email address in linode's DNS service, update the play-linode.yml 
playbook accordingly.  After terraform has created the nodes and inserted them into DNS domain, you can run the 
ansible playbook for the CentOS systems using the `inventory` file and the Debian/Ubuntu systems using the 
`inventory_py3` file.  These will correctly create the gitlab service on these hosts with https enabled.

Inputs:

  - password - string - root password used to create the instance
  - ssh\_key - string - description = "The ssh public key used in instance's authorized_hosts
  - image - string - Linode Image type to use
  - script - string - script to execute after Linode is running
  - region - string - The Linode region to use
  - type - string - The image size type to use
  - label - string - The label used to create the instance and hostname
  - domain - string - pre-existing Linode-managed DNS domain to assign public IP of created instance
  - inventory - string - pre-existing inventory file used for ansible to append instance info into

Outputs:

  - id - string - linode\_instance.this.id
  - ip\_address - string - linode\_instance.this.ip\_address
  - private\_ip\_address - string - linode\_instance.this.private\_ip\_address`
  - ipv6 - string - linode\_instance.this.ipv6
  - ipv4 - string - linode\_instance.this.ipv4
  - backups - string - linode\_instance.this.backups


#### [ec2-instance](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance)

I had to fork this repository to add the provisioner commands and augment the inputs. Now this will append 
to the inventory file and rather than using scripts, the `user_data` input to `aws_instance` will be 
passed a text string.

```
module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"

  name                   = "my-cluster"
  instance_count         = 5

  ami                    = "ami-ebd02392"
  instance_type          = "t2.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = ["sg-12345678"]
  subnet_id              = "subnet-eddcdzz4"
  user_data = <<-EOF
    #!/bin/bash
    # configure CentOS 8 to use ansible

    dnf install -y epel-release
    dnf config-manager --set-enabled powertools
    dnf makecache
    dnf install -y ansible
    alternatives --set python /usr/bin/python3
  EOF

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

Inputs and Outputs

see the module [README](https://github.com/mvilain/terraform-aws-ec2-instance/blob/master/README.md)


#### [vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc)

This module is way overkill used to create subnets for public, private, database, elastic cache, and 
other services.  Also, it outputs things that you can't just plug into other modules as their types 
are incompatible. Since this is a demo project rather than something that will be run in production, 
the `aws-vpc.tf` file will create a simple vpc with a publicly accessible subnet, gateway, routes, and 
security group to access it.

```
provider "aws" {
  region = local.region
}

locals {
  region = "us-east-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "github-example"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "gitlab-subnet"
  }

  tags = {
    Owner       = "user"
    Environment = "gitlab"
  }

  vpc_tags = {
    Name = "gitlab-vpc"
  }
}
```

See the [README](https://github.com/terraform-aws-modules/terraform-aws-vpc) on github for a full list of all 
159 inputs (18 required) and 108 outputs.


## TODO

- haproxy round-robin will not cycle if a host in the proxy list is down

won't respond to ping?  It's OK if node is up but http doesn't respond to heartbeat

- setup gitlab instances to point to a single postgresql server and use haproxy to load balance between them.


- refactor the linode inventory build design to use

  - https://github.com/ansible-collections/community.general/blob/main/scripts/inventory/linode.ini
  - https://github.com/ansible-collections/community.general/blob/main/scripts/inventory/linode.py

## Appendix A

### Repo has submodules

Since this repo has submodules, you'll need to clone it and populate the submodules:

    git clone --recurse-submodules https://github.com/mvilain/gitlab.git


### adding submodule to git

This creates a HEADless snapshot of the submodule in the main repo.

    cd ~/gitlab/linode/terraform-modules
    git submodule add git@github.com:mvilain/terraform-linode-instance.git
    cd ~/gitlib/aws/terraform-modules
    git submodule add git@github.com:mvilain/terraform-aws-ec2-instance.git

When you update the submodule and push it, the snapshot must be refreshed with the changes.

    git submodule update
    git submodule update --remote
    git commit -a -m "submodule update"

### removing submodules from git

Here's how to remove submodules (from [How to delete a submodule](https://gist.github.com/myusuf3/7f645819ded92bda6677))

- Delete the relevant section from the .gitmodules file.
- Stage the .gitmodules changes `git add .gitmodules`
- Delete the relevant section from .git/config.
- Run `git rm --cached path_to_submodule` (no trailing slash).
- Run `rm -rf .git/modules/path_to_submodule` (no trailing slash).
- Delete the now untracked submodule files `rm -rf path_to_submodule`
- Commit `git commit -m "Removed submodule"`
