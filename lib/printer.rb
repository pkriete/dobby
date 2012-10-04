HELP_TEXT = <<-EOS
usage: dobby [--help] <command|path>

Control running services:
  dobby info                show available services
  dobby status              show running services
  dobby start SERVICE       start a service
  dobby stop SERVICE        stop a service
  dobby restart SERVICE     restart a service

Configurations:
  dobby edit SERVICE        open a configuration file
EOS


class Printer
  class <<self

    # Everyone loves colored output!

    def red text; "\033[0;31m#{text}\033[0m"; end
    def green text; "\033[0;92m#{text}\033[0m"; end

    # Takes a 2d array [[key, value], [ke, va]] and prints
    # it as two columns. TODO more than two columns?
    #
    def columns data
      longest = data.map { |item| item[0].length}.sort.last

      data.each do |item|
        printf "%-#{longest+10}s %s\n", item[0], item[1]
      end
    end

    # Show an error message
    #
    def error msg
      puts "#{self.red 'Error:'}\033[0m #{msg}"
      exit 1
    end

    # Show the help text
    #
    def help 
      puts HELP_TEXT
    end
  end
end