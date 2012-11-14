require 'lib/runner'
require 'lib/commands'

module Dobby

  VERSION = '0.1.0'

  @@files = {}

  # Loads and parses a config file.
  #
  # This is set up to  allow multiple files, but the frontend
  # currently doesn't know who to call when that happens.
  #
  def self.load(filename)
    if not @@files[filename]
      dsl = Runner.new
      dsl.instance_eval(File.read(filename), filename)

      @@files[filename] = Commands.new(dsl)
    end

    @@files[filename]
  end

  # Execute a shell command
  #
  # TODO safety checks!
  #
  def self.execute(command)    
    system(command)
  end

  # Run a dobby command from inside dobby
  #
  # If we need to drop to root it will restart with
  # that action as the new command. This means that
  # nothing can happen after a run call!
  #
  def self.run(service, command)
    if service.needs_root? && ENV['USER'] != 'root'
      exec("sudo #{ENV['_']} #{DOBBY_BIN} #{command} #{service.name}")
    end
    
    command = "do_#{command}"
    service.send(command.to_sym)
  end

  # Delay execution and alert user
  #
  def self.delay
    puts "Delaying ..."
    sleep 1
  end

  # Everyone's favorite versioning scheme
  #
  def self.version
    VERSION
  end

end