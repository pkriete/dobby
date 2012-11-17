module ServiceCommands

  attr_writer :parent

  # Check if process is running, and if so restart
  def do_edit(args = [])
    puts "Waiting on editor ..."
    Dobby.execute("#{ENV['EDITOR']} #{get_value 'file'}")
    puts "Error Editing" if $?.exitstatus != 0

    # Attempt to restart
    do_restart
  end

  def do_start(args = [])
    # check for flags
    command = get_value('start')
    if command.respond_to?('call')
      command = command.call(args)
    end
    
    # In truth what I want to do here is call exec on the command and have it
    # take over completely. Especially since a lot of the target processes for
    # dobby aren't daemons and there is no point in having the ruby process hang
    # around waiting for nothing.
    #
    # However, for now I'm using system so that I can catch SIGUSR1 as a restart
    # signal and do a self-referential exec to restart.
    #
    # TODO There might be a way to start it, grab the pid, and then sleep.
    # That way the PID could be stored by dobby and the sigusr command could
    # kill that particular process.

    Dobby.execute(command)
  end


  def do_stop(args = [])
    command = get_value('stop')
    if command
      Dobby.execute(command)
    else
      send_stern_message('TERM') # 'KILL'
    end
  end


  # Force a restart
  #
  # This method will try various restarting options
  #
  def do_restart(args = [])

    # If there is a parent dependency and this is not our own
    # process (php vs apache) then the parent should be restarted

    if not running?
      Dobby.run(@parent, 'restart') if @parent
      return
    end

    puts "Restarting #{@name} ..."
    restart_cmd = get_value('restart')

    if restart_cmd
      Dobby.execute(restart_cmd)
      return
    end

    start_cmd = get_value('start')

    # if we have start and stop we can fake it given that there were
    # no parameters used to start it.
    if can_stop?
      unless start_cmd.respond_to?('call') # potentially has parameters
        do_stop
        do_start
        return
      end
    end

    # Here's the deal, for now we shut down everything, but only try to restart
    # those that we started. Doing anything more requires figuring out how the
    # user started the process. That's as fun as it sounds.

    send_stern_message('USR1')
  end

  # Convenience Methods

  def can_start?
    return self.start != nil
  end

  def can_stop?
    return self.stop != nil
  end

  def is_editable?
    return self.file != nil
  end

  def needs_root?
    return @needs_root
  end

  # Check if a process is running
  # Investigate switching to pgrep
  def running?
    return false unless @process

    test = `pgrep #{@process} | wc -l 2>/dev/null`.strip.to_i
    #test = `ps aux | grep #{@process} | wc -l 2>/dev/null`.strip.to_i
    test > 1 # one for grep and one for the ruby `sh -c`
  end

  private

    def get_value(attrib)
      if self.respond_to?(attrib)
        value = self.send(attrib.to_sym)
      end

      if value == nil && @parent.respond_to?(attrib)
        value = @parent.send(:get_value, attrib)
      end

      value
    end

    def send_stern_message(message)
      proc = @process || @id
      nogreppid = "grep -v grep | tr -s ' ' | cut -d' ' -f2"

      # The order here seems backwards, but isn't.
      # Dobby.rb traps USR1 and forces a restart with a --delay flag.
      # Delaying the restart lets us clean up any leftover processes before we
      # attempt to start another one (looking at you, jekyll).

      # Killing the dobby parent before the process would result in the parent
      # finishing and we'd have nothing to restart.

      pids = `ps aux | grep dobby | grep -v stop | grep -v restart | grep #{@id} | #{nogreppid}`
      pids.split(/\n/).each do |process|
        Process.kill(message, process.to_i)
      end

      # nom nom nom

      #leftoverpids = `ps aux | grep #{proc} | grep -v dobby | #{nogreppid}`
      leftoverpids = `pgrep #{proc}`
      leftoverpids.split(/\n/).each do |process|
        `kill #{process}`
      end
    end

end