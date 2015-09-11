## -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

#############################
## 20141221
## Alvaro Miranda
## http://kikitux.net
## alvaro at kikitux.net
## Mikael Sandström
## http://oravirt.wordpress.com
## oravirt at gmail.com
##
## 20150911
## Modified to be used outside
## of RACATTACK
## 
#############################
#### BEGIN CUSTOMIZATION ####
#############################
path_to_vagrant_insec_key = /home/miksan/.vagrant.d/insecure_private_key
#define number of nodes
num_APPLICATION       = 0
num_LEAF_INSTANCES    = 0
num_DB_INSTANCES      = 2
#
#define number of cores for guest
num_CORE              = 2
#
#define memory for each type of node in MBytes
#
#for leaf nodes, the minimun can be  2300, otherwise pre-check will fail for
#automatic ulimit values calculated based on ram
#
#for database nodes, the minimum suggested is 3072 for standard cluster
#for flex cluster, consider 4500 or more
#
memory_APPLICATION    = 1500
memory_LEAF_INSTANCES = 2300
memory_DB_INSTANCES   = 4096
#        
#size of shared disk in GB
size_shared_disk      = 4
#number of shared disks
count_shared_disk     = 6
#
#############################
##### END CUSTOMIZATION #####
#############################

#create inventory for ansible to run
inventory_ansible = File.open("inventory","w")
inventory_ansible << "[vbox-rac-application]\n"
(1..num_APPLICATION).each do |i|
  inventory_ansible << "appnode#{i} ansible_ssh_user=vagrant ansible_ssh_private_key_file=#{path_to_vagrant_insec_key} ansible_ssh_args='-o UserKnownHostsFile=/dev/null'\n"
end
inventory_ansible << "[vbox-rac-leaf]\n"
(1..num_LEAF_INSTANCES).each do |i|
  inventory_ansible << "dblnode#{i} ansible_ssh_user=vagrant ansible_ssh_private_key_file=#{path_to_vagrant_insec_key} ansible_ssh_args='-o UserKnownHostsFile=/dev/null'\n"
end
inventory_ansible << "[vbox-rac-hub]\n"
(1..num_DB_INSTANCES).each do |i|
  inventory_ansible << "dbnode#{i} ansible_ssh_user=vagrant ansible_ssh_private_key_file=#{path_to_vagrant_insec_key} ansible_ssh_args='-o UserKnownHostsFile=/dev/null'\n"
end
inventory_ansible << "[vbox-rac:children]\n"
inventory_ansible << "vbox-rac-leaf\n" if num_LEAF_INSTANCES > 0
inventory_ansible << "vbox-rac-hub\n"  if num_DB_INSTANCES > 0
inventory_ansible << "[vbox-rac-all:children]\n"
inventory_ansible << "vbox-rac-application\n"  if num_APPLICATION > 0
inventory_ansible << "vbox-rac-leaf\n" if num_LEAF_INSTANCES > 0
inventory_ansible << "vbox-rac-hub\n"  if num_DB_INSTANCES > 0
inventory_ansible.close

$etc_hosts_script = <<SCRIPT
#!/bin/bash
grep PEERDNS /etc/sysconfig/network-scripts/ifcfg-eth0 || echo 'PEERDNS=no' >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "overwriting /etc/resolv.conf"
cat > /etc/resolv.conf <<EOF
nameserver 192.168.78.51
nameserver 192.168.78.52
nameserver 10.0.2.3
search internal.lab dbnode.internal.lab
EOF

cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost6 localhost6.localdomain6
EOF
SCRIPT

#variable used to provide information only once
give_info ||=true

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.ssh.insert_key = false
  config.vm.box = "oravirt/ol65"
 

  ## Virtualbox modifications
  ## we first setup memory and cpu
  ## we create shared disks if they don't exists
  ## we later attach the disk to the vms
  ## we attach to each vm, as in the future we may want to have say 2db + 2app cluster
  ## we can attach 2 shared disk for db to the db nodes only
  ## and 2 other shared disks for the app

  if File.directory?("stagefiles")
    # our shared folder for scripts
    config.vm.synced_folder "stagefiles", "/media/stagefiles", :mount_options => ["dmode=555","fmode=444","gid=54321"]
    #clean all
    if ENV['setup'] == "clean"
      config.vm.provision :shell, :inline => "sh /media/stagefiles/clean.sh YES"
    else
      #run some scripts
      config.vm.provision :shell, :inline => $etc_hosts_script
    end
  end

  if File.directory?("swrepo")
    # our shared folder for oracle 12c installation files
    config.vm.synced_folder "swrepo", "/media/swrepo", :mount_options => ["dmode=777","fmode=777","uid=54320","gid=54321"]
  end

  ## IMPORTANT
  ## vagrant work up to down, high node goes first
  ## so when node 1 is ready, we can configure rac and all nodes will be up

  (1..num_APPLICATION).each do |i|
    # this is to start machines higher to lower
    i = num_APPLICATION+1-i
    config.vm.define vm_name = "appnode%01d" % i do |config|
      puts " "
      config.vm.hostname = "#{vm_name}.internal.lab"
      lanip = "192.168.78.#{i+90}"
      puts vm_name + " eth1 lanip  :" + lanip
      config.vm.provider :virtualbox do |vb|
        vb.name = vm_name + "." + Time.now.strftime("%y%m%d%H%M")
        vb.customize ["modifyvm", :id, "--memory", memory_APPLICATION]
        vb.customize ["modifyvm", :id, "--cpus", num_CORE]
        vb.customize ["modifyvm", :id, "--groups", "/vbox-rac"]
      end
      config.vm.network :private_network, ip: lanip
    end
  end

  (1..num_LEAF_INSTANCES).each do |i|
    # this is to start machines higher to lower
    i = num_LEAF_INSTANCES+1-i
    config.vm.define vm_name = "dblnode%01d" % i do |config|
      puts " "
      config.vm.hostname = "#{vm_name}.internal.lab"
      lanip = "192.168.78.#{i+70}"
      puts vm_name + " eth1 lanip  :" + lanip
      privip = "172.16.100.#{i+70}"
      puts vm_name + " eth2 privip :" + privip
      config.vm.provider :virtualbox do |vb|
        vb.name = vm_name + "." + Time.now.strftime("%y%m%d%H%M")
        vb.customize ["modifyvm", :id, "--memory", memory_LEAF_INSTANCES]
        vb.customize ["modifyvm", :id, "--cpus", num_CORE]
        vb.customize ["modifyvm", :id, "--groups", "/vbox-rac"]
      end
      config.vm.network :private_network, ip: lanip
      config.vm.network :private_network, ip: privip
    end
  end

  (1..num_DB_INSTANCES).each do |i|
    # this is to start machines higher to lower
    i = num_DB_INSTANCES+1-i
    config.vm.define vm_name = "dbnode%01d" % i do |config|
      puts " "
      config.vm.hostname = "#{vm_name}.internal.lab"
      lanip = "192.168.78.#{i+50}"
      puts vm_name + " eth1 lanip  :" + lanip
      privip = "172.16.100.#{i+50}"
      puts vm_name + " eth2 privip :" + privip
      config.vm.provider :virtualbox do |vb|
        vb.name = vm_name + "." + Time.now.strftime("%y%m%d%H%M")
        vb.customize ["modifyvm", :id, "--memory", memory_DB_INSTANCES]
        vb.customize ["modifyvm", :id, "--cpus", num_CORE]
        vb.customize ["modifyvm", :id, "--groups", "/vbox-rac"]
        vb.customize ['createhd', '--filename', "#{vm_name}-extra-disk1.vdi", '--size', (50 * 1024).floor, '--variant', 'standard']
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', "#{vm_name}-extra-disk1.vdi"]
        #first shared disk port
        port=2
        #how many shared disk
        (1..count_shared_disk).each do |disk|
          file_to_dbdisk = "vbox-rac-shared-disk"
          if !File.exist?("#{file_to_dbdisk}#{disk}.vdi")
            unless give_info==false
              puts "on first boot shared disks will be created, this will take some time"
              give_info=false
            end
            vb.customize ['createhd', '--filename', "#{file_to_dbdisk}#{disk}.vdi", '--size', (size_shared_disk * 1024).floor, '--variant', 'fixed']
            vb.customize ['modifyhd', "#{file_to_dbdisk}#{disk}.vdi", '--type', 'shareable']
          end
          vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', port, '--device', 0, '--type', 'hdd', '--medium', "#{file_to_dbdisk}#{disk}.vdi"]
          port=port+1
        end
      end
      config.vm.network :private_network, ip: lanip
      config.vm.network :private_network, ip: privip
      if not ENV['setup'] == "clean"
        if vm_name == "dbnode1" 
          puts vm_name + " dns server role is master"
          config.vm.provision :shell, :inline => "sh /media/stagefiles/named_master.sh"
        end
        if vm_name == "dbnode2" 
          puts vm_name + " dns server role is slave"
          config.vm.provision :shell, :inline => "sh /media/stagefiles/named_slave.sh"
        end
      end
    end
  end


end
