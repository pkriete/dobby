require "lib/service"

# Defines the configuration language used for the config file.
class Runner

  attr_reader :services

  def initialize
     @services = {}
  end

  # Config and service items
  #
  # I may break these up in the future, but for now they
  # are simply an alias. Also not sure I love "services"
  # as a name.
  #
  def config name, &block
    item = Service.new(name)
    yield item
    @services[item.id] = item
  end
  alias_method :service, :config

  # Scripted tasks pipe dream
  #
  # This would work by creating a series of tasks. Example:
  #
  # $ dobby vhosts add example.com
  # > Creating folder
  # > Adding vhost config
  # > Editing hosts file
  # > Restarting apache
  #
  def task name, &block
    return
  end

end