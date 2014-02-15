# Defines the configuration language used for the config file.
module Dobby
  class DSL

    attr_reader :service_definitions

    def initialize
       @service_definitions = {}
    end

    # Config and service items
    #
    # I may break these up in the future, but for now they
    # are simply an alias. Also not sure I love "services"
    # as a name.
    #
    def config(name, &block)
      item = DSLServiceDefinition.new(name)
      yield item
      @service_definitions[item.id] = item
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
    def task(name, &block)
      return
    end

  end
end