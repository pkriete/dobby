# Class used for the block of the config dsl method
class Service

  protected

    attr_reader :file, :process, :start, :stop, :restart

  public
  
    attr_reader :id, :parent_id
    attr_writer :file, :process, :start, :stop, :restart, :needs_root

    attr_accessor :name
    
    def initialize(moniker)
      if not moniker.respond_to?('first')
        @id = moniker
      else
        @id, @parent_id = moniker.first
      end

      @process = nil
      @needs_root = false
    end
end
