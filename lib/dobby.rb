$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'dobby/printer'
require 'dobby/dsl'
require 'dobby/dsl_service_definition'
require 'dobby/service'
require 'dobby/services'
require 'dobby/commands'

require 'dobby/config'

module Dobby
  extend self

  VERSION = '0.1.0'

  @@startup = true

  # Start
  #
  # `dobby command [service [args]]`
  #
  def start(config_file)
    config = Config.new(config_file)

    svc = Services.new(config)
    cmd = Commands.new(svc)

    if not ARGV.service
      return cmd.exec()
    end

    cmd.exec(svc.get_current_service(), ARGV.args)
  end

  # From here on down it's all utility

  def execute(command)
    system(command)
  end

  # Run a dobby command from inside dobby
  #
  # If we need to drop to root it will restart with
  # that action as the new command. The startup
  # procedure needs work, it's a little opaque.
  #
  def run(service, command, args = [])

    shell_cmd = "#{DOBBY_COMMAND} #{command} "
    shell_cmd << "#{service.name().shellescape} "
    shell_cmd << args.join(' ').shellescape

    if service.needs_root? && ENV['USER'] != 'root'
      exec("sudo #{shell_cmd}")
    end

    exec("#{shell_cmd}") unless @@startup

    @@startup = false
    command = "do_#{command}"

    service.send(command.to_sym, args)
  end

  # Delay execution and alert user
  #
  def delay
    puts "Delaying ..."
    sleep 1
  end
end