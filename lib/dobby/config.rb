module Dobby
  class Config

    attr_reader :service_definitions

    # Parsing the config file is really just running the file in the
    # Context of our DSL
    def initialize(file)

      if not File.exists?(file)
        Printer.error '~/.dobby_config file not found.'
      end

      dsl = DSL.new
      dsl.instance_eval(File.read(file), file)

      @service_definitions = dsl.service_definitions
    end

    def get_service_defintion(name)
      @service_definitions[name.downcase.to_sym]
    end
  end
end