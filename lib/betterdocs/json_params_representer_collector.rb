module Betterdocs
  # Collects and manages documented JSON parameters for a
  # representer module.
  class JsonParamsRepresenterCollector
    # Initializes an empty parameter map.
    def initialize
      @params = {}
    end

    # Returns the internal parameter map keyed by symbol name.
    #
    # @return [Hash<Symbol, Betterdocs::Dsl::JsonParams::Param>]
    attr_reader :params

    # Looks up a single param by name.
    #
    # @param param_name [String, Symbol] the param name
    # @return [Betterdocs::Dsl::JsonParams::Param, nil]
    def param(param_name)
      param_name = param_name.to_sym
      @params[param_name]
    end

    # Builds a documentation element and registers it with this
    # collector.
    #
    # @param representer [String] the representer module name
    # @param type [Symbol] the element type
    # @param name [Symbol] the parameter name
    # @param options [Hash] keyword options for the element
    # @yield documentation block for the element
    def add_element(representer, type, name, **options, &block)
      element = build_element(representer, type, name, options, &block)
      element.add_to_collector(self)
    end

    # Returns the name of the first representer that has one set.
    #
    # @return [String, nil] the representer name
    def representer
      @params.values.find { |v|
        v.representer and break v.representer
      }
    end

    # Renders a human-readable text summary of all documented params.
    #
    # @return [String]
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

    # Instantiates the appropriate `Dsl::JsonParams` subclass.
    #
    # @param representer [String] the representer module name
    # @param type [Symbol] the element type
    # @param args [Array] additional positional arguments
    # @yield documentation block for the element
    # @return [Betterdocs::Dsl::JsonParams::Param]
    # @raise [ArgumentError] if the type does not map to a known class
    def build_element(representer, type, *args, &block)
      begin
        element = Dsl::JsonParams.const_get(type.to_s.camelcase)
      rescue NameError
        raise ArgumentError, "unknown documentation element type #{type.inspect}"
      end
      element.new(representer, *args, &block)
    end
  end
end
