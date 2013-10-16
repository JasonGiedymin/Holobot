# vm.rb

# Standard procs that build VMs
module StandardVMLib
  def StandardVMLib.prepare 
    Proc.new do |os_name, config, props|
      # puts "Sleeping 10 seconds to wait for networking..."

      # installs
      config.vm.provision :shell, inline: props[:scripts][:restartNetworking]

      # sleep 10 # let vm networking catch up

      config.vm.provision :shell, inline: props[:scripts][:upgrade]
      config.vm.provision :shell, inline: props[:scripts][:installs]
    end
  end

  def StandardVMLib.strider
    Proc.new do |os_name, config, props|
      config.vm.provision :shell, inline: props[:scripts][:strider]
    end
  end

  def StandardVMLib.registry 
    Proc.new do |os_name, config, props|
      config.vm.provision :shell, inline: props[:scripts][:registry]
    end
  end

  def StandardVMLib.etcd
    Proc.new do |os_name, config, props|
      # replace etcd, only needed if etcd version is NOT up to date
      if (COMPILE_CUSTOM_ETCD)
        box.vm.provision :shell, inline: props[:scripts][:replace_etcd_ubuntu]
      end
    end
  end

  def StandardVMLib.runChef
    Proc.new do |os_name, config, props|
      # chef
      config.omnibus.chef_version = :latest #Define omnibus client to utilize

      config.vm.provision "chef_solo" do |chef|
        chef.log_level = :debug
        chef.cookbooks_path = [
          "#{HOME_SCRIPTS}/berkshelf", 
          "#{HOME_SCRIPTS}/cookbooks"
        ]

        # chef.data_bags_path = "#{HOME_SCRIPTS}/data_bags"

        chef.json = props[:chef][:json]

        # os
        chef.add_recipe "apt" # make sure this is always first!!!
        chef.add_recipe "build-essential" # make sure this is always second!!!
           
        # simple
        chef.add_recipe "python"
        chef.add_recipe "golang"
        chef.add_recipe "nodejs"
        
        # finally end with these installs resulting in systemic changes
        chef.add_recipe "docker" # though this does get installed by mesos!
        chef.add_recipe "etcd"

        # long running
        chef.add_recipe "java"
        chef.add_recipe "scala"
      end

      # config.berkshelf.enabled = true
    end
  end

  def StandardVMLib.finishMessage
    Proc.new do |os_name, config, props|
      config.vm.provision :shell, inline: "echo '#{props[:appname]}-#{os_name} started...'"
    end
  end

  def StandardVMLib.mesos
    Proc.new do |os_name, config, props|
      config.vm.provision :shell, inline: props[:scripts][:mesos]
    end
  end
      
  def StandardVMLib.ubuntuCleanup
    Proc.new do |os_name, config, props|
      config.vm.provision :shell, inline: props[:scripts][:cleanup]
    end
  end

  def StandardVMLib.network
    Proc.new do |os_name, config, props|
      # Network
      node_mac = baseNode(os_name)['mac']
      private_ip = baseNode(os_name)['private_ip']

      config.vm.network :private_network, ip: private_ip#, :adapter => 2 # assigned to adapter 2 by default

      if (CONFIG.arch == 64)
        # the main card configuration
        config.vm.network :public_network, :bridge => 'en0: Wi-Fi (AirPort)', :mac => node_mac#, :adapter => 3
      else
        # yes we are actually specifying adapter 3 in 32 arch
        config.vm.network :public_network, :bridge => 'en0: Wi-Fi (AirPort)', :mac => node_mac, :adapter => 3
      end

      #config.ssh.username = 'core'
      #config.ssh.forward_agent = true
      #config.ssh.timeout = 500
      #config.ssh.max_tries = 40
    end
  end

  # why does nfs mounting not work half the time?
  def StandardVMLib.mounts
    Proc.new do |os_name, config, props|
      use_nfs = baseOSNode(os_name)['nfs']
      config.vm.synced_folder HOME_NFS_MOUNT, REMOTE_NFS_MOUNT, id: "vagrant-root", :nfs => true # requires root privs
    end
  end

  def StandardVMLib.hypervisorSettings
    Proc.new do |os_name, config, props|
      # Vbox specific configs, should think about removing these
      mem = baseOSNode(os_name)['mem']
      cpu = baseOSNode(os_name)['cpu']
      disk = baseOSNode(os_name)['disk']
      disk_uri = "#{HOME_BASE_BOX}/#{disk}"

      config.vm.provider :virtualbox do |vb|
        puts "Using #{CONFIG.get('arch')}bit arch settings..."

        
        vb.customize ["modifyvm", :id, "--cpus", cpu] #making sure cpus are accounted at min
        # vb.customize ["modifyvm", :id, "--cpuexecutioncap", 50]
        vb.customize ["modifyvm", :id, "--memory", mem] #min ram to build box
        
        if (CONFIG.get('arch') == 64)
          # vb.customize ["modifyvm", :id, "--ioapic", "on"]
          # vb.customize ["modifyvm", :id, "--acpi", "off"]
          vb.customize ["modifyvm", :id, "--hwvirtex", "on"] #in case it is needed
        
          # by default pae is on! Turning it off will force the vm to switch PAE modes DURING boot
          # which is NOT recommended, this is a bug for sure!
          vb.customize ["modifyvm", :id, "--pae", "on"]

          # vb.customize ["modifyvm", :id, "--rtcuseutc", "on"] # should be on by default
        else
          puts "Using 32bit arch settings..."
          vb.customize ["modifyvm", :id, "--ioapic", "off"]
          vb.customize ["modifyvm", :id, "--hwvirtex", "off"]
          vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]
        end

        # # Disks
        # if ( disk.length > 0 && File.exists?(disk_uri))
        #   #vb.customize ["storageattach", :id, "--type", 'hdd']
        #   vb.customize ["storageattach", :id, "--medium", disk_uri]
        # end

        # vb.gui = true #just in case
      end
    end
  end
end

# Standard VM
class StandardVM
  def initialize(os_name, config, box, props, box_file='', pre=[], post=[])
    box.vm.box = "#{props[:appname]}-#{os_name}"
    box.vm.box_url = "#{HOME_BASE_BOX}/#{box_file}" if (box_file.length > 0)

    standardOps = []
    standardOps.push(StandardVMLib.hypervisorSettings)
    standardOps.push(StandardVMLib.network)
    standardOps.push(StandardVMLib.mounts) if baseOSNode(os_name)['mounts']
    standardOps.concat(pre)
    standardOps.push(StandardVMLib.runChef) if baseOSNode(os_name)['chef']
    standardOps.push(StandardVMLib.etcd) if baseOSNode(os_name)['etcd']
    standardOps.concat(post)
    standardOps.push(StandardVMLib.finishMessage)
    standardOps.each{ |x| x.call(os_name, config, props) }
  end
end
