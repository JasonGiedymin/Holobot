# system_helper

STRICT_MODE = true

def shell_cmd(location, cmd, action_message)
  chdir(location)

  if STRICT_MODE
    if system cmd
      puts "-> Action [#{action_message}] complete\n\n"
    else
        raise "\n!!!\n   Error trying to #{action_message}\n!!!\n\n"
    end
  elsif
    system cmd
  end # end strict
end # end vm_cmd