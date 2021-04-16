# -*- mode: ruby -*-
# vi: set ft=ruby :

# gitlab demo Vagrant file to spin up multiple machines and OS'
# Maintainer Michael Vilain [202103.18]

Vagrant.configure("2") do |config|
  # config.vm.network 'forwarded_port', guest: 80, host: 8080
  config.vm.synced_folder '.', '/vagrant', disabled: false
  config.ssh.insert_key = false
#   config.ssh.username = 'root'
#   config.ssh.password = 'vagrant'
  config.vm.boot_timeout = 120
  config.vm.provider :virtualbox do |vb|
    #vb.gui = true
    vb.memory = '4096'
  end
  #
  # provision on all machines to allow ssh w/o checking
  #
  config.vm.provision "shell", inline: <<-SHELLALL
#     cat /vagrant/etc-hosts >> /etc/hosts
    echo "...disabling CheckHostIP..."
    sed -i.orig -e "s/#   CheckHostIP yes/CheckHostIP no/" /etc/ssh/ssh_config
  SHELLALL


  config.vm.define "gitlab7" do |gitlab7|
    gitlab7.vm.box = "centos/7"
    gitlab7.ssh.insert_key = false
    gitlab7.vm.network 'private_network', ip: '192.168.10.107'
    gitlab7.vm.hostname = 'gitlab7'
    gitlab7.vm.provision "shell", inline: <<-SHELL
#      yum install -y epel-release
#       yum install -y python3 libselinux-python3 #python36-rpm
    SHELL
    # still uses python2 for ansible
    gitlab7.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end
  
  # https://bugzilla.redhat.com/show_bug.cgi?id=1820925
  # use AlmaLinux CentOS fork 202104.03
  config.vm.define "gitlab8" do |gitlab8|
#     gitlab8.vm.box = "centos/8"
    gitlab8.vm.box = "almalinux/8"
    gitlab8.ssh.insert_key = false
    gitlab8.vm.network 'private_network', ip: '192.168.10.108'
    gitlab8.vm.hostname = 'gitlab8'
    gitlab8.vm.provision "shell", inline: <<-SHELL
      dnf install -y epel-release
      dnf config-manager --set-enabled powertools
      dnf makecache
      dnf install -y ansible
      alternatives --set python /usr/bin/python3
    SHELL
    gitlab8.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end


  # https://stackoverflow.com/questions/56460494/apt-get-install-apt-transport-https-fails-in-docker
  config.vm.define "gitlab9" do |gitlab9|
    gitlab9.vm.box = "debian/stretch64"
    gitlab9.ssh.insert_key = false
    gitlab9.vm.network 'private_network', ip: '192.168.10.109'
    gitlab9.vm.hostname = 'gitlab9'
    gitlab9.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y apt-transport-https python-apt
    SHELL
    gitlab9.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end

  # don't use apt: update_cache=yes here because it won't work to trap
  # repo change errors like with Debian 10 because of apt-secure server
  config.vm.define "gitlab10" do |gitlab10|
    gitlab10.vm.box = "debian/buster64"
    gitlab10.ssh.insert_key = false
    gitlab10.vm.network 'private_network', ip: '192.168.10.110'
    gitlab10.vm.hostname = 'gitlab10'
    gitlab10.vm.provision "shell", inline: <<-SHELL
      apt-get update --allow-releaseinfo-change -y
      apt-get install -y apt-transport-https
    SHELL
    gitlab10.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end

# deprecated notice for gitlab on Ubuntu 16 4/15/2021
  config.vm.define "gitlab16" do |gitlab16|
    gitlab16.vm.box = "ubuntu/xenial64"
    gitlab16.vm.network 'private_network', ip: '192.168.10.116'
    gitlab16.vm.hostname = 'gitlab16'
    gitlab16.vm.provision "shell", inline: <<-SHELL
      apt-get -y install python3
    SHELL
    gitlab16.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end

  # ansible uses python3 1/7/21
  config.vm.define "gitlab18" do |gitlab18|
    gitlab18.vm.box = "ubuntu/bionic64"
    gitlab18.vm.network 'private_network', ip: '192.168.10.118'
    gitlab18.vm.hostname = 'gitlab18'
    gitlab18.vm.provision "shell", inline: <<-SHELL
      apt-get -y install python3
    SHELL
    gitlab18.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end

  # https://www.reddit.com/r/Ubuntu/comments/ga187h/focal64_vagrant_box_issues/
  # 1/7/21 earlier focal64 didn't work w/ vagrant, fixed
  # requires setting ansible_python_interpreter=/usr/bin/python3 
  config.vm.define "gitlab20" do |gitlab20|
    gitlab20.vm.box = "ubuntu/focal64"
    #gitlab20.vm.box = "bento/ubuntu-20.04"
    gitlab20.vm.network 'private_network', ip: '192.168.10.120'
    gitlab20.vm.hostname = 'gitlab20'
    gitlab20.vm.provision "shell", inline: <<-SHELL
      apt-get -y install python3
    SHELL
    gitlab20.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end

end
