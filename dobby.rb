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

require 'lib/main'
require 'lib/printer'

# Catch startup delay
if ARGV.last == '--delay'
  ARGV.pop
  Dobby.delay
end

# Grab command
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

# Extend argv
require 'lib/argv'
ARGV.extend(DobbyArgv)

# Here's a sock. Now go do your work!
Dobby.start(cmd, File.expand_path(DOBBY_CONFIG_FILE))