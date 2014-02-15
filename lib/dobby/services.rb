
module Dobby
  class Services

    include Enumerable

    attr_writer :parent

    def initialize(config)

      @defs = config.service_definitions
      @services = Hash.new

      @defs.each do |k, v|
        @services[k] = Service.new(v)
      end

      @services.each do |k, v|
        v.parent = @services[v.parent_id]
      end

      if ARGV.service
        @requested_service = @services[ARGV.service.to_sym]
      end
    end

    def each
      @services.each { |e| yield(e) }
    end

    def get_current_service()
      @requested_service
    end

    def get_service(name)
      return @services
    end

  end
end