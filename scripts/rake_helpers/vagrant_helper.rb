# Vagrant helpers for Rakefiles
#
# Usage:
#   import <this file>
#
# Note: this helper requires vars which may only exist
#       in a root rakefile (the importer)
#

# -----------------------------CONSTS-------------------------------------------

SUPPORTED_OS=[
  'ubuntu',
  'coreos'
]

# Setting mode to weak because vagrant doesn't work with
# coreos correctly atm. It works but warnings pop up and
# this will cause system commands to fail.
VAGRANT_STRICT_MODE = false

VagrantCommand = Struct.new(:task, :desc, :cmd)

VAGRANT_CMDS = [
  VagrantCommand.new('up', 'Start vm', 'up'),
  VagrantCommand.new('halt', 'Stop vm', 'halt'),
  VagrantCommand.new('destroy', 'Destroy and cleanup vm', 'destroy --force')
]

# -----------------------------METHODS------------------------------------------

def chdir(dir)
  Dir.chdir("#{dir}")
end

def vm_cmd(os, cmd)
  chdir("#{HOME_VAGRANT_BOX}")
  vagrant_cmd = "vagrant #{cmd}"

  if VAGRANT_STRICT_MODE
    if system vagrant_cmd
      puts "-> Vagrant command ran: [#{vagrant_cmd}]\n\n"
    else
        raise "\n!!!\n   Error trying to run vagrant command [#{vagrant_cmd}]\n!!!\n\n"
    end
  elsif
    system vagrant_cmd
  end # end weak
end # end vm_cmd

def say(word)
  puts "Hi #{word}"
end


namespace :vm do
  SUPPORTED_OS.each do |os|

    namespace os do
      VAGRANT_CMDS.each do |command|

        desc command.desc
        task command.task do |t|
          vm_cmd(os, command.cmd)
        end # end dynamic task

      end # end command each
    end # end namespace os

  end # end os
end # end vm
