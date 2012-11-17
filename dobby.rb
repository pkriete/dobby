require 'pathname'

# Change this to your config file path
DOBBY_CONFIG_FILE = '~/.dobby_config'


# Here's a sock. Now go do your work!

DOBBY_BIN = Pathname.new(__FILE__).realpath
DOBBY_PATH = DOBBY_BIN.dirname
$:.unshift(DOBBY_PATH)

# Saving this for root-ing and restart purposes
DOBBY_COMMAND = "#{ENV['_']} #{DOBBY_BIN} #{ARGV.join(' ')}"

# Catch restart signal
Signal.trap("USR1") do
  exec DOBBY_COMMAND + " --delay"
end

require 'lib/main'
require 'lib/printer'

# Catch startup delay
if ARGV.last == '--delay'
  ARGV.pop
  Dobby.delay
end


cmd = ARGV.shift

# Help text
if not cmd || %w(-h --help help).include?(cmd)
  Printer.help
  exit cmd ? 0 : 1
end

# Version
if %w(-v --version).include?(cmd)
  puts "Dobby #{Dobby.version}"
  exit 0
end

# Parse config file
config = Dobby.load(File.expand_path(DOBBY_CONFIG_FILE))


# Catch invalid commands
if not config.respond_to?(cmd)
  Printer.error 'Command not found.'
end

# Extend argv
require 'lib/argv'
ARGV.extend(DobbyArgv)

# TODO Error handling

# Go go go!
config.send(cmd.to_sym, ARGV)