# git_helpers.rb

def clone(name, url, dir)
  puts "Cloning [ #{name} via #{url} ]"
  shell_cmd(
    "./",
    "git clone #{url} #{dir}/#{name}",
    "cloning repository #{url}"
  )
end

