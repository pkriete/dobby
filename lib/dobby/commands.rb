
# Knows about all the service config and contains the
# cli logic to start/stop/etc the right service. This is what
# you interact with when you type in dobby <command>
#
module Dobby
  class Commands

    def initialize(services)
      @services = services
      @command = ARGV.command.to_sym
    end

    def exec(*options)
      if options.first
        @service = options.shift()
      end

      if not self.respond_to?(@command) or @command == :exec
        Printer.error 'Command not found.'
      end

      self.public_send(@command, options)
    end

    # Public Commands

    def info(args)
      Printer.columns list
    end

    def edit(args)
      run('edit', args)
    end

    def start(args)
      run('start', args)
    end

    def stop(args)
      run('stop', args)
    end

    def restart(args)
      run('restart', args)
    end

    def status(args)
      running = []
      @services.each do |k, v|
        if v.can_start?
          if v.running?
            running.push [k.to_s, "#{Printer.green 'running'}"]
          else
            running.push [k.to_s, "#{Printer.red 'stopped'}"]
          end
        end
      end

      # It just so happens that 'running' comes before 'stopped'
      # in the alphabet, so we can do a simple multisort.
      Printer.columns running.sort { |a, b| [b[1], a[0]] <=> [a[1], b[0]] }
    end


    # Semi-public Commands
    #
    # All of these currently start with list_ which prevents them from being
    # listed in the autcomplete, which is incidentally also why they exist in
    # the first place.
    #
    def list_commands(args)
      puts Commands.instance_methods(false).reject { |item| item[/(^list_|exec)/] }
    end

    def list_services(args)
      startable = @services.select { |_, v| v.can_start? }
      puts startable.collect { |item| item[0].to_s }.sort
    end

    def list_configs(args)
      editable = @services.select { |_, v| v.is_editable? }
      puts editable.collect { |item| item[0].to_s }.sort
    end

    def list_running(args)
      running = @services.select { |_, v| v.can_start? && v.running? }
      puts running.collect { |item| item[0].to_s }.sort
    end


    private

      def printer
        Dobby.Printer
      end

      def run(cmd, args)
        if @service and @service.respond_to?("do_#{cmd}")
          Dobby.run(@service, cmd, args)
        else
          info(nil)
        end
      end

      def all
        @services.sort_by { |key, _| key.to_s }
      end

      def list
        all.map { |item| [item[0].to_s, item[1].name]}
      end
  end
end