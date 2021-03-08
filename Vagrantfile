# -*- mode: ruby -*-
# vi: set ft=ruby :

# gitlab demo Vagrant file to spin up multiple machines
# Maintainer Michael Vilain [202103.08]


Vagrant.configure(2) do | config |
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box = 'centos/7'
  # config.vm.network 'forwarded_port', guest: 80, host: 8080
  config.ssh.insert_key = false
  config.vm.synced_folder '.', '/vagrant', disabled: false
  config.vm.provider :virtualbox do |vb|
    #vb.gui = true
    vb.memory = '1024'
  end

  # provision on all machines -- set hosts and allow ssh w/o checking
  config.vm.provision "shell", inline: <<-SHELLALL
    cat /vagrant/etc-hosts >> /etc/hosts
    sed -i.orig -e "s/#   CheckHostIP yes/CheckHostIP no/" /etc/ssh/ssh_config
  SHELLALL

  # run ansible playbook on all nodes...node-specific stuff is in the playbook
  config.vm.provision "ansible" do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.playbook = "site.yml"
    ansible.inventory_path = "./inventory"
    # ansible.verbose = "v"
    # ansible.raw_arguments = [""]
  end

  config.vm.define "gl1" do | gl1 | 
    gl1.vm.network 'private_network', ip: '192.168.10.101'
    gl1.vm.hostname = 'gl1'
  end

  config.vm.define "gl2" do | gl2 |
    gl2.vm.network 'private_network', ip: '192.168.10.102'
    gl2.vm.hostname = 'gl2'
  end

  config.vm.define "gl3" do | gl3 |
    gl3.vm.network 'private_network', ip: '192.168.10.103'
    gl3.vm.hostname = 'gl3'
  end

  config.vm.define "lbr1", primary: true do | lbr1 |
    lbr1.vm.network 'private_network', ip: '192.168.10.100'
    lbr1.vm.hostname = 'lbr1'
  end

end
