# Vagrant helpers for Rakefiles
#
# Usage:
#   import <this file>
#
# Note: this helper requires vars which may only exist
#       in a root rakefile (the importer)
#

# -----------------------------CONST--------------------------------------------

SUPPORTED_OS=[
  'ubuntu',
  'coreos'
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

VAGRANT_CMDS = [
  VagrantCommand.new('up', 'Start vm', 'up'),
  VagrantCommand.new('halt', 'Stop vm', 'halt'),
  VagrantCommand.new('destroy', 'Destroy and cleanup vm', 'destroy --force'),
  VagrantCommand.new('ssh', 'SSH onto vm', 'ssh'),
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
    #puts "-> Vagrant command ran: [#{vagrant_cmd}]\n\n"
    system vagrant_cmd
  end # end weak
end # end vm_cmd

def say(word)
  puts "Hi #{word}"
end


namespace :baseboxes do
  def curl(name, url)
    puts "Downloading base box [ #{name} via #{url} ]"
    if system "curl #{url} > #{HOME_BASE_BOX}/#{name}.box"
      puts "-> Base box #{name} downloaded to [#{HOME_BASE_BOX}/#{name}.box].\n\n"
    else
      raise "\n!!!\n   Error downloading base box: #{url}\n!!!\n\n"
    end
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
    end # end namespace os

  end # end os

  VAGRANT_CMDS.each do |command|
    os=DEFAULT_OS
    desc "#{command.desc} #{os}"
    task command.task do |t|
      vm_cmd(os, command.cmd)
    end # end default vm task
  end # end default command each

end # end vm
