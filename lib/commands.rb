require 'lib/service_commands'

# Knows about all the service config and contains the
# cli logic to start/stop/etc the right service. This is what
# you interact with when you type in dobby <command>
#
class Commands

  def initialize(dsl)
    @services = Hash.new
    dsl.services.each do |k, v|
      @services[k] = v.extend ServiceCommands
      v.parent = @services[v.parent_id]
    end
  end

  # Public Commands

  def info(args)
    Printer.columns list
  end

  def edit(args)
    conf = get(args[0])
    conf ? conf.do_edit : info(nil)
  end

  def start(args)
    conf = get(args[0])
    conf ? conf.do_start : info(nil)
  end

  def stop(args)
    conf = get(args[0])
    conf ? conf.do_stop : info(nil)
  end

  def restart(args)
    conf = get(args[0])
    conf ? conf.do_restart : info(nil)
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
    puts Commands.instance_methods(false).reject { |item| item[/^list_/] }
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

    def get(id)
      @services[id.downcase.to_sym]
    end

    def all
      @services.sort_by { |key, _| key.to_s }
    end

    def list
      all.map { |item| [item[0].to_s, item[1].name]}
    end

end