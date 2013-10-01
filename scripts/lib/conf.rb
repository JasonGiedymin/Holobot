# conf.rb - Holobot config reader
#
# Sample Usage:
#   puts( '=> ' + HoloConfig.new('../conf').mode )
#

require 'yaml'

module Nodes
  Keys = ['version', 'mode', 'arch', 'mac']
end

class HoloConfig

  def metaclass
    class << self; self; end
  end
  
  def initialize(conf_location)
    @conf_location = conf_location
    @core_file = 'core.yml'
    @user_file = 'user.yml'

    Nodes::Keys.each{ |x| 
      metaclass.send(:define_method, x) do
        raise "No config info found for '#{x}'' in user.yml or core.yml files." unless check?(x)
        get(x)
      end
    }
  end

  def core
    YAML::load_file([@conf_location, @core_file].join('/'))
  end

  def user
    YAML::load_file([@conf_location, @user_file].join('/'))
  end

  # Gets the yaml node value from the user config
  # otherwise gets from core yaml file.
  def check?(node)
    if user[node] || core[node]
      true
    else 
      false
    end
  end

  def get(node)
    user[node] || core[node]
  end
end

