require 'pathname'
require 'shellwords'

# Change this to your config file path
DOBBY_CONFIG_FILE = '~/.dobby_config'

DOBBY_BIN = Pathname.new(__FILE__).realpath
DOBBY_PATH = DOBBY_BIN.dirname
$:.unshift(DOBBY_PATH)

# For root-ing and restart purposes
DOBBY_COMMAND = "#{ENV['_']} #{DOBBY_BIN}"

# Catch restart signal
Signal.trap("USR1") do
  exec(DOBBY_COMMAND + ARGV.join(' ').shellescape + " --delay")
end

require 'lib/dobby'
require 'lib/dobby/argv'
ARGV.extend(DobbyArgv)

# Catch startup delay
if ARGV.last == '--delay'
  Dobby.delay
end

cmd = ARGV.command


# Help text
if ARGV.command == nil || %w(-h --help help).include?(cmd)
  Dobby::Printer.help
  exit cmd ? 0 : 1
end

# Version
if %w(-v --version).include?(cmd)
  Dobby::Printer.version
  exit 0
end

# Here's a sock. Now go do your work!
Dobby.start(File.expand_path(DOBBY_CONFIG_FILE))