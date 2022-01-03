# -*- mode: ruby -*-
# vi: set ft=ruby :

# gitlab demo Vagrant file to spin up multiple machines and OS'
# Maintainer Michael Vilain [202104.28]
# 202112.14 removed ubuntu 16.04 as no longer supported; added rockylinux

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
    echo "...disabling CheckHostIP..."
    sed -i.orig -e "s/#   CheckHostIP yes/CheckHostIP no/" /etc/ssh/ssh_config
  SHELLALL

  config.vm.define "gitlab2" do |gitlab2|
    gitlab2.vm.box = "bento/amazonlinux-2"
    gitlab2.ssh.insert_key = false
    gitlab2.vm.network 'private_network', ip: '192.168.10.102'
    gitlab2.vm.hostname = 'gitlab2.text'
    gitlab2.vm.provision "shell", inline: <<-SHELL
      amazon-linux-extras install epel #ansible2=2.8 kernel-ng python3.8
      yum-config-manager --enable epel
      # alternatives --set python /usr/bin/python3.8
      # python3.8 -m pip install --upgrade pip setuptools
    SHELL
    gitlab2.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory_vagrant"
    end
  end

# vagrant box has python2.7 installed with /usr/libexec/platform-python
  config.vm.define "gitlab7" do |gitlab7|
    gitlab7.vm.box = "centos/7"
    gitlab7.ssh.insert_key = false
    gitlab7.vm.network 'private_network', ip: '192.168.10.107'
    gitlab7.vm.hostname = 'gitlab7.text'
    gitlab7.vm.provision "shell", inline: <<-SHELL
#      yum install -y epel-release
#       yum install -y python3 libselinux-python3 #python36-rpm
    SHELL
    # still uses python2 for ansible
    gitlab7.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory_vagrant"
    end
  end

  # https://bugzilla.redhat.com/show_bug.cgi?id=1820925
  # centos/8, almalinux/7, and rockylinux/8 have no /usr/bin/python or /usr/bin/python3 installed
  config.vm.define "gitlab8" do |gitlab|
    # requires setting ansible_python_interpreter=/usr/bin/python3
    gitlab.vm.box = "geerlingguy/centos8"   # python3
    gitlab.ssh.insert_key = false
    gitlab.vm.network 'private_network', ip: '192.168.10.108'
    gitlab.vm.hostname = 'gitlab8.text'
    gitlab.vm.provision "shell", inline: <<-SHELL
      dnf install -y epel-release
      dnf config-manager --set-enabled powertools
      dnf makecache
      dnf install -y ansible
      alternatives --set python /usr/bin/python3
    SHELL
    gitlab.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory_vagrant"
    end
  end

  config.vm.define "gitlabr8" do |gitlabr8|
#     gitlab8.vm.box = "centos/8"
    gitlabr8.vm.box = "rockylinux/8"
    gitlabr8.ssh.insert_key = false
    gitlabr8.vm.network 'private_network', ip: '192.168.10.208'
    gitlabr8.vm.hostname = 'gitlabr8.text'
    gitlabr8.vm.provision "shell", inline: <<-SHELL
      dnf install -y epel-release
      dnf config-manager --set-enabled powertools
      dnf makecache
      dnf install -y ansible
      alternatives --set python /usr/bin/python3
    SHELL
    gitlabr8.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory_vagrant"
    end
  end

  # https://stackoverflow.com/questions/56460494/apt-get-install-apt-transport-https-fails-in-docker
  config.vm.define "gitlab9" do |gitlab9|
    gitlab9.vm.box = "bento/debian-9"
    gitlab9.ssh.insert_key = false
    gitlab9.vm.network 'private_network', ip: '192.168.10.109'
    gitlab9.vm.hostname = 'gitlab9.text'
    gitlab9.vm.provision "shell", inline: <<-SHELL
      apt-get update --allow-releaseinfo-change -y
      apt-get install -y apt-transport-https python-apt
    SHELL
    gitlab9.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory_vagrant"
    end
  end

  # don't use apt: update_cache=yes here because it won't work to trap
  # repo change errors like with Debian 10 because of apt-secure server
  config.vm.define "gitlab10" do |gitlab10|
    gitlab10.vm.box = "bento/debian-10"
    gitlab10.ssh.insert_key = false
    gitlab10.vm.network 'private_network', ip: '192.168.10.110'
    gitlab10.vm.hostname = 'gitlab10.text'
    gitlab10.vm.provision "shell", inline: <<-SHELL
      apt-get update --allow-releaseinfo-change -y
      apt-get install -y apt-transport-https python-apt
    SHELL
    gitlab10.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory_vagrant"
    end
  end

  config.vm.define "gitlab11" do |gitlab11|
    gitlab11.vm.box = "bento/debian-11"
    gitlab11.ssh.insert_key = false
    gitlab11.vm.network 'private_network', ip: '192.168.10.111'
    gitlab11.vm.hostname = 'gitlab11.text'
    gitlab11.vm.provision "shell", inline: <<-SHELL
      apt-get update --allow-releaseinfo-change -y
      apt-get install -y apt-transport-https python-apt
    SHELL
    gitlab11.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory_vagrant"
    end
  end

  # ansible uses python3 1/7/21
  config.vm.define "gitlab18" do |gitlab18|
    gitlab18.vm.box = "ubuntu/bionic64"
    gitlab18.vm.network 'private_network', ip: '192.168.10.118'
    gitlab18.vm.hostname = 'gitlab18.text'
    gitlab18.vm.provision "shell", inline: <<-SHELL
      apt-get -y install python3
    SHELL
    gitlab18.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory_vagrant"
    end
  end

  # https://www.reddit.com/r/Ubuntu/comments/ga187h/focal64_vagrant_box_issues/
  # 1/7/21 earlier focal64 didn't work w/ vagrant, fixed
  # requires setting ansible_python_interpreter=/usr/bin/python3
  config.vm.define "gitlab20" do |gitlab20|
    gitlab20.vm.box = "ubuntu/focal64"
    #gitlab20.vm.box = "bento/ubuntu-20.04"
    gitlab20.vm.network 'private_network', ip: '192.168.10.120'
    gitlab20.vm.hostname = 'gitlab20.text'
    gitlab20.vm.provision "shell", inline: <<-SHELL
      apt-get -y install python3
    SHELL
    gitlab20.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory_vagrant"
    end
  end

 # https://www.reddit.com/r/Ubuntu/comments/ga187h/focal64_vagrant_box_issues/
  # 1/7/21 earlier focal64 didn't work w/ vagrant, fixed
  # requires setting ansible_python_interpreter=/usr/bin/python3
  config.vm.define "lbr20" do |lbr|
    lbr.vm.box = "ubuntu/focal64"
    #lbr.vm.box = "bento/ubuntu-20.04"
    lbr.vm.network 'private_network', ip: '192.168.10.100'
    lbr.vm.hostname = 'lbr20.text'
    lbr.vm.provision "shell", inline: <<-SHELL
      apt-get -y install python3
    SHELL
    lbr.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory_vagrant"
    end
  end

end
