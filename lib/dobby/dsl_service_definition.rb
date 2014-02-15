
# Simple Service Definition
#
# For each block in the DSL, we instantiate one of these classes.
#
#
module Dobby
  class DSLServiceDefinition

    attr_reader :id, :parent_id

    attr_accessor :name, :file, :process, :start, :stop, :restart, :needs_root

    def initialize(moniker)
      if not moniker.respond_to?(:first)
        @id = moniker
      else
        @id, @parent_id = moniker.first
      end

      @process = nil
      @needs_root = false
    end

  end
end