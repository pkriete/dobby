require 'lib/runner'
require 'lib/commands'

module Dobby

  extend self

  VERSION = '0.1.0'

  @@startup = true

  # Start
  #
  def start(cmd, config_file)
    # Parse config file
    config = self.load(config_file)

    # Catch invalid commands
    if not config.respond_to?(cmd)
      Printer.error 'Command not found.'
    end

    # Go go go!
    config.send(cmd.to_sym, ARGV)
  end

  # Loads and parses a config file.
  #
  def load(filename)
    dsl = Runner.new
    dsl.instance_eval(File.read(filename), filename)
    Commands.new(dsl)
  end

  # Execute a shell command
  #
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
    shell_cmd << "#{service.name.shellescape} "
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

  # Everyone's favorite versioning scheme
  #
  def version
    VERSION
  end

end