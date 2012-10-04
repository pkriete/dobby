require "lib/runner"
require "lib/commands"

module Dobby

  VERSION = '0.1.0'

  @@files = {}

  # Loads and parses a config file.
  #
  # This is set up to  allow multiple files, but the frontend
  # currently doesn't know who to call when that happens.
  #
  def self.load filename
    if not @@files[filename]
      dsl = Runner.new
      dsl.instance_eval(File.read(filename), filename)

      @@files[filename] = Commands.new dsl
    end

    @@files[filename]
  end

  # Execute a shell command
  #
  # TODO safety checks!
  #
  def self.execute command, needs_root
    # Drop to root if required
    if needs_root && ENV['USER'] != 'root'
      exec "sudo #{DOBBY_COMMAND}"
    end
    
    system command
  end

  # Everyone's favorite versioning scheme
  #
  def self.version
    VERSION
  end

end