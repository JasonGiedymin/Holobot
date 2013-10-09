# Vagrant helpers for Rakefiles
#
# Usage:
#   import <this file>
#
# Note: this helper requires vars which may only exist
#       in a root rakefile (the importer)
#

# -----------------------------CONST--------------------------------------------

require "#{HOME_LIB}/conf.rb"
CONFIG = HoloConfig.new(HOME_CONF)

SUPPORTED_OS=[
  'ubuntu',
  'coreos',
  'strider'
]

# We also define a primary in the multi machine Vagrantfile.
# but here we define it specificaly anyway to be double safe and is why we
# will use this const later.
DEFAULT_OS=SUPPORTED_OS[0]

# Setting mode to weak because vagrant doesn't work with
# coreos correctly atm. It works but warnings pop up and
# this will cause system commands to fail.
VAGRANT_STRICT_MODE = false

VagrantCommand = Struct.new(:task, :desc, :cmd)

# Simple custom commands here
# If more complex commands are necessary, drop down to
# the `namespace: vm` section below.
VAGRANT_CMDS = [
  VagrantCommand.new('up', 'Start vm', 'up'),
  VagrantCommand.new('halt', 'Stop vm', 'halt'),
  VagrantCommand.new('suspend', 'Suspend suspended vm', 'suspend'),
  VagrantCommand.new('resume', 'Resume a suspended vm', 'resume'),
  VagrantCommand.new('destroy', 'Destroy and cleanup vm', 'destroy --force'),
  VagrantCommand.new('ssh', 'SSH onto vm', 'ssh'),
  VagrantCommand.new('provision', 'Provision vm', 'provision')
]

# -----------------------------METHODS------------------------------------------



def chdir(dir)
  Dir.chdir("#{dir}")
end

def vm_cmd(os, cmd)
  chdir("#{HOME_VAGRANT_BOX}")
  vagrant_cmd = "vagrant #{cmd} #{os}"

  if VAGRANT_STRICT_MODE
    if system vagrant_cmd
      puts "-> Vagrant command ran: [#{vagrant_cmd}]\n\n"
    else
        raise "\n!!!\n   Error trying to run vagrant command [#{vagrant_cmd}]\n!!!\n\n"
    end
  elsif
    system vagrant_cmd
  end # end strict
end # end vm_cmd

def say(word)
  puts "Hi #{word}"
end


namespace :baseboxes do
  def curl(name, url)
    puts "Downloading base box [ #{name} via #{url} ]"
    Dir.mkdir(HOME_BASE_BOX) unless Dir.exists?(HOME_BASE_BOX)

    shell_cmd(
      "./",
      "curl #{url} > #{HOME_BASE_BOX}/#{name}.box",
      "Download base box #{name} to [#{HOME_BASE_BOX}/#{name}.box]"
    )
  end

  desc "Update base boxes"
  task :download do
    BASE_BOX_URLS.each_pair do |name, box_info|
      # If the file doesn't exist get it
      # otherwise if it does already exist
      # then only get it if tracking is enabled
      if !File.exists?("#{HOME_BASE_BOX}/#{name}.box")
        curl(name, box_info['url'])
      else # File exists, but only get if tracking is on
        curl(name, box_info['url']) if box_info['track']
      end
    end
  end
end


namespace :vm do
  SUPPORTED_OS.each do |os|

    namespace os do
      VAGRANT_CMDS.each do |command|

        desc "#{command.desc} #{os}"
        task command.task do |t|
          vm_cmd(os, command.cmd)
        end # end dynamic task

      end # end command each

      desc "Removes #{CONFIG.version}-#{os} from vagrant."
      task :cleanup do
        Rake::Task["vm:destroy"].invoke
        vm_cmd('virtualbox', "box remove #{CONFIG.version}-#{os}")
      end

      desc 'Rebirth does a force destroy followed by an up'
      task :rebirth do
        Rake::Task["vm:#{os}:destroy"].invoke
        Rake::Task["vm:#{os}:cleanup"].invoke
        Rake::Task["vm:#{os}:up"].invoke
      end

      desc "Reboots the #{os} vm"
      task :reboot do
        Rake::Task["vm:#{os}:halt"].invoke
        Rake::Task["vm:#{os}:up"].invoke
      end

    end # end namespace os

  end # end os

  VAGRANT_CMDS.each do |command|
    os=DEFAULT_OS
    desc "#{command.desc} #{os}"
    task command.task do |t|
      vm_cmd(os, command.cmd)
    end # end default vm task
  end # end default command each


  desc 'Cleanup up the vagrant dir'
  task :cleanup do
    Rake::Task["vm:destroy"].invoke
    vm_cmd('virtualbox', "box remove #{CONFIG.version}-#{DEFAULT_OS}")
  end
  
  desc 'Rebirth does a force destroy followed by an up'
  task :rebirth do
    Rake::Task["vm:destroy"].invoke
    Rake::Task["vm:cleanup"].invoke
    Rake::Task["vm:up"].invoke
  end

  desc 'Reboots a vm'
  task :reboot do
    Rake::Task["vm:halt"].invoke
    Rake::Task["vm:up"].invoke
  end

end # end vm
