require 'active_support/time_with_zone'

require 'betterdocs/dsl/naming'

# A documented JSON request parameter. Extends {Betterdocs::Dsl::Representer}
# with naming, type mapping, and value computation for deserializing
# incoming API payloads.
class Betterdocs::Dsl::JsonParams::Param < Betterdocs::Dsl::Representer
  extend Tins::DSLAccessor
  include Betterdocs::Dsl::Common
  include Betterdocs::Dsl::Naming

  # @!method description
  #
  # @overload description
  #   Returns the human-readable description of the parameter.
  #
  #   @note Defaults to `"TODO"`.
  #   @return [String] the description
  #
  # @overload description(description)
  #   Sets the description.
  #
  #   @param description [String] the description
  #   @return [String] the description
  dsl_accessor :description, 'TODO'

  # @!method value
  #
  # @overload value
  #   Returns the example value shown in the generated documentation.
  #
  #   @note Defaults to `"TODO"`.
  #   @return [String] the example value
  #
  # @overload value(value)
  #   Sets the example value.
  #
  #   @param value [String] the example value
  #   @return [String] the example value
  dsl_accessor :value, 'TODO'

  # @!method types
  #
  # @overload types
  #   Returns the mapped JSON types for this parameter (see
  #   {Betterdocs::Dsl::JsonTypeMapper}).
  #
  #   @note No explicit value set, so the default block is re-evaluated
  #     on each read: an empty array, later mapped in `initialize`.
  #   @return [Array<String>] the JSON types
  #
  # @overload types(types)
  #   Sets the JSON types.
  #
  #   @param types [Array<String>] the JSON types
  #   @return [Array<String>] the JSON types
  dsl_accessor :types do [] end

  # @!method required
  #
  # @overload required
  #   Returns whether this parameter is required in the request.
  #
  #   @note Defaults to `true`.
  #   @return [Boolean] whether the param is required
  #
  # @overload required(flag)
  #   Sets whether the param is required.
  #
  #   @param flag [Boolean] the flag
  #   @return [Boolean] the flag
  dsl_accessor :required, true

  # Initializes the param, then maps its Ruby types to JSON types.
  #
  # @param representer [Module] the including representer module
  # @param name [Symbol] the parameter name
  # @param options [Hash] options forwarded to {Betterdocs::Dsl::Representer}
  def initialize(representer, name, options, &block)
    super
    types Betterdocs::Dsl::JsonTypeMapper.map_types(types)
  end

  # Assigns the computed value into the result hash if the
  # {#assign?} condition passes.
  #
  # @param result [Hash] the target hash to populate
  # @param object [Object] the source object to read from
  def assign(result, object)
    assign?(object) or return
    result[name] = compute_value(object)
  end

  # Reads the value from +object+ using the param's name, extending
  # it with {Betterdocs::JsonTimeWithZone} if it responds to
  # `:iso8601`.
  #
  # @param object [Object] the source object
  # @return [Object] the extracted (and possibly extended) value
  def compute_value(object)
    value = object.__send__(name)
    value.respond_to?(:iso8601) and value.extend Betterdocs::JsonTimeWithZone
    value
  end

  # Registers this param with the given collector.
  #
  # @param collector [Betterdocs::JsonParamsRepresenterCollector] the target
  def add_to_collector(collector)
    collector.params[name] = self
  end
end
