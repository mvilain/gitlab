# gitlab -- install and configure gitlab with load balancers

This project uses Vagrant to create three GitLab servers, a database server, and
a haproxy load balancer to cycle between the three servers.  All three servers
keep their database of users and repositories in the database server.

## Requirements

This project uses several roles that are in the transition to becoming 2.9's new Collections.  So that this project will run on 2.8, I've used these as roles rather than full-on collections which require 2.9.

- ansible-role-apache
- ansible-role-nginx

https://docs.ansible.com/ansible/latest/collections/community/general/gitlab_project_module.html

These modules work well in creating default setups for apache and nginx.

Here's how to remove submodules:

- Delete the relevant section from the .gitmodules file.
- Stage the .gitmodules changes git add .gitmodules
- Delete the relevant section from .git/config.
- Run git rm --cached path_to_submodule (no trailing slash).
- Run rm -rf .git/modules/path_to_submodule (no trailing slash).
- Commit git commit -m "Removed submodule "
- Delete the now untracked submodule files rm -rf path_to_submodule

from [https://gist.github.com/myusuf3/7f645819ded92bda6677](How to delete a submodule)


- ansible-role-haproxy  --> haproxy

This role sets up haproxy without any monitoring page and doesn't automatically add servers to the configuration from an ansible group.  If you use the http health check provided, the default install of apache 2.4 will return 'Forbidden' which will fail.

Also, the haproxy process doesn't agregate logs in a separate file.

Instead of using this role as is, combine the features of it with my own module.

- [https://github.com/geerlingguy/ansible-role-gitlab](ansible-role-gitlab) was created in 2014 and is a bit old

it doesn't use the gitlab installation repos in

[https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh]

from [https://about.gitlab.com/install/#centos-7](Installing Gitlab on CentoS 7)



## to do

- haproxy round-robin will not cycle if a host in the proxy list is down

won't respond to ping?  It's OK if node is up but http doesn't respond to heartbeat



https://medium.com/sopra-steria-norge/managing-your-infrastructure-with-ansible-and-gitlab-ci-cd-c820188270d6

### .gitlab-ci.yml

'
stages:
    - dev
    - test


image: registry.gitlab.com/torese/docker-ansible

variables:
    ANSIBLE_HOST_KEY_CHECKING: 'false'
    ANSIBLE_FORCE_COLOR: 'true'

.run_playbook:
    allow_failure: false
    tags:
        - aws
    script:
        - ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa 2>/dev/null <<< y >/dev/null
        - rm -f ~/.ssh/id_rsa.pub
        - echo "-----BEGIN RSA PRIVATE KEY-----" > ~/.ssh/id_rsa
        - echo $SSH_PRIVATE_KEY | tr ' ' '\n' | tail -n+5 | head -n-4 >> ~/.ssh/id_rsa
        - echo "-----END RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa

        - ansible-playbook playbook.yml -u automation --private-key=~/.ssh/id_rsa \
              -i $inventory -e "app_servers=$hosts"

deploy_dev:
    extends: .run_playbook
    variables:
        inventory: inventory
        hosts: dev 
    stage: dev
    environment: Dev

        
deploy_test:
    extends: .run_playbook
    variables:
        inventory: inventory
        hosts: test 
    stage: test
    environment: Test
'