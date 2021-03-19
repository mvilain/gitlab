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


  config.vm.define "c7" do |c7|
    c7.vm.box = "centos/7"
    c7.ssh.insert_key = false
    c7.vm.network 'private_network', ip: '192.168.10.107'
    c7.vm.hostname = 'c7'
    c7.vm.provision "shell", inline: <<-SHELL
#      yum install -y epel-release
#       yum install -y python3 libselinux-python3 #python36-rpm
    SHELL
    c7.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end
  
  # https://bugzilla.redhat.com/show_bug.cgi?id=1820925
  config.vm.define "c8" do |c8|
    c8.vm.box = "centos/8"
    c8.ssh.insert_key = false
    c8.vm.network 'private_network', ip: '192.168.10.108'
    c8.vm.hostname = 'c8'
    c8.vm.provision "shell", inline: <<-SHELL
      dnf install -y epel-release
      dnf config-manager --set-enabled powertools
      dnf makecache
      dnf install -y ansible python3-firewall
      alternatives --set python /usr/bin/python3
    SHELL
    c8.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end


  # https://stackoverflow.com/questions/56460494/apt-get-install-apt-transport-https-fails-in-docker
  config.vm.define "d9" do |d9|
    d9.vm.box = "debian/stretch64"
    d9.ssh.insert_key = false
    d9.vm.network 'private_network', ip: '192.168.10.109'
    d9.vm.hostname = 'd9'
    d9.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y apt-transport-https python-apt
    SHELL
    d9.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end

  # don't use apt: update_cache=yes here because it won't work to trap
  # repo change errors like with Debian 10 because of apt-secure server
  config.vm.define "d10" do |d10|
    d10.vm.box = "debian/buster64"
    d10.ssh.insert_key = false
    d10.vm.network 'private_network', ip: '192.168.10.110'
    d10.vm.hostname = 'd10'
    d10.vm.provision "shell", inline: <<-SHELL
        apt-get update --allow-releaseinfo-change -y
        apt-get install -y apt-transport-https
    SHELL
    d10.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end


  config.vm.define "u16" do |u16|
    u16.vm.box = "ubuntu/xenial64"
    u16.vm.network 'private_network', ip: '192.168.10.116'
    u16.vm.hostname = 'u16'
        u16.vm.provision "shell", inline: <<-SHELL
            apt-get -y install python3
        SHELL
    u16.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end

  # ansible uses python3 1/7/21
  config.vm.define "u18" do |u18|
    u18.vm.box = "ubuntu/bionic64"
    u18.vm.network 'private_network', ip: '192.168.10.118'
    u18.vm.hostname = 'u18'
        u18.vm.provision "shell", inline: <<-SHELL
            apt-get -y install python3
        SHELL
    u18.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end

  # https://www.reddit.com/r/Ubuntu/comments/ga187h/focal64_vagrant_box_issues/
  # 1/7/21 earlier focal64 didn't work w/ vagrant, fixed
  # requires setting ansible_python_interpreter=/usr/bin/python3 
  config.vm.define "u20" do |u20|
      u20.vm.box = "ubuntu/focal64"
        #u20.vm.box = "bento/ubuntu-20.04"
    u20.vm.network 'private_network', ip: '192.168.10.120'
    u20.vm.hostname = 'u20'
        u20.vm.provision "shell", inline: <<-SHELL
            apt-get -y install python3
        SHELL
    u20.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
    end
  end

end
