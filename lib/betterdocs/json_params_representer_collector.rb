module Betterdocs
  class JsonParamsRepresenterCollector
    def initialize
      @params = {}
    end

    attr_reader :params

    def param(param_name)
      param_name = param_name.to_sym
      @params[param_name]
    end

    def add_element(representer, type, name, **options, &block)
      element = build_element(representer, type, name, options, &block)
      element.add_to_collector(self)
    end

    def representer
      @params.values.find { |v|
        v.representer and break v.representer
      }
    end

    def to_s
      result = "*** #{representer} ***\n"
      if params = @params.values.full?
        result << "\nProperties:"
        params.each_with_object(result) do |param, r|
          r << "\n#{param.full_name}: (#{param.types * '|'}): #{param.description}\n"
        end
      end
      result
    end

    private

    def build_element(representer, type, *args, &block)
      begin
        element = Dsl::JsonParams.const_get(type.to_s.camelcase)
      rescue NameError => e
        raise ArgumentError, "unknown documentation element type #{type.inspect}"
      end
      element.new(representer, *args, &block)
    end
  end
end

