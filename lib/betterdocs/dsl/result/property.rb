require 'active_support/time_with_zone'

require 'betterdocs/dsl/representer'
require 'betterdocs/dsl/common'
require 'betterdocs/dsl/naming'
require 'betterdocs/dsl/json_type_mapper'

# A documented property in an API response. Extends
# {Betterdocs::Dsl::Representer} with naming, type mapping,
# sanitization, and optional nested representer support.
class Betterdocs::Dsl::Result::Property < Betterdocs::Dsl::Representer
  extend Tins::DSLAccessor
  include Betterdocs::Dsl::Common
  include Betterdocs::Dsl::Naming

  # @!method represent_with
  #
  # @overload represent_with
  #   Returns the nested {Betterdocs::ResultRepresenter} module used to
  #   represent this property's value.
  #
  #   @note Defaults to `nil`.
  #   @return [Module, nil] the sub-representer
  #
  # @overload represent_with(module)
  #   Sets the sub-representer.
  #
  #   @param module [Module] a `Betterdocs::ResultRepresenter`
  #   @return [Module] the sub-representer
  dsl_accessor :represent_with

  # @!method description
  #
  # @overload description
  #   Returns the human-readable description of the property.
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

  # @!method example
  #
  # @overload example
  #   Returns the example value shown in the generated documentation.
  #
  #   @note Defaults to `"TODO"`.
  #   @return [String] the example value
  #
  # @overload example(example)
  #   Sets the example value.
  #
  #   @param example [String] the example value
  #   @return [String] the example value
  dsl_accessor :example, 'TODO'

  # @!method types
  #
  # @overload types
  #   Returns the mapped JSON types for this property.
  #
  #   @note Defaults to `nil`.
  #   @return [Array<String>, nil] the JSON types
  #
  # @overload types(types)
  #   Sets the JSON types.
  #
  #   @param types [Array<String>] the JSON types
  #   @return [Array<String>] the JSON types
  dsl_accessor :types

  # @!method optional
  #
  # @overload optional
  #   Returns whether this property is optional in the response.
  #
  #   @note Defaults to `nil`.
  #   @return [Boolean, nil] whether the property is optional
  #
  # @overload optional(flag)
  #   Sets whether the property is optional.
  #
  #   @param flag [Boolean] the flag
  #   @return [Boolean] the flag
  dsl_accessor :optional

  # @!method sanitize
  #
  # @overload sanitize
  #   Returns the sanitization proc for string values.
  #
  #   @note No explicit value set, so the default block is re-evaluated
  #     on each read: `Betterdocs::Global.default_sanitize`.
  #   @return [Proc, nil] the sanitizer proc
  #
  # @overload sanitize(proc)
  #   Sets the sanitizer proc.
  #
  #   @param proc [Proc] a proc receiving a String and returning a
  #     sanitized String
  #   @return [Proc] the sanitizer proc
  dsl_accessor :sanitize do Betterdocs::Global.default_sanitize end

  # Initializes the property, maps types, and validates the
  # sub-representer if one is given.
  #
  # @param representer [Module] the including representer module
  # @param name [Symbol] the property name
  # @param options [Hash] options including `:as` for aliasing
  # @raise [TypeError] if `represent_with` is not a
  #   `Betterdocs::ResultRepresenter`
  def initialize(representer, name, options, &block)
    super
    types Betterdocs::Dsl::JsonTypeMapper.map_types(types)
    if sr = sub_representer?
      sr < Betterdocs::ResultRepresenter or
        raise TypeError, "#{sr.inspect} is not a Betterdocs::Result subclass"
    end
  end

  # Returns the sub-representer module if `represent_with` is set.
  #
  # @return [Module, nil] the nested representer, or nil
  def sub_representer?
    represent_with
  end

  # Returns the public name for this property, honouring the `:as`
  # option.
  #
  # @return [String] the property name as it appears in the JSON output
  def actual_property_name
    (options[:as] || name).to_s
  end

  # Assigns the computed value into the result hash under the
  # property's public name.
  #
  # @param result [Hash] the target hash to populate
  # @param object [Object] the source object to read from
  def assign(result, object)
    assign?(object) or return
    result[actual_property_name] = compute_value(object)
    self
  end

  # Computes the property value from +object+, applying the
  # sub-representer, ISO 8601 time extension, or sanitizer as
  # appropriate.
  #
  # @param object [Object] the source object
  # @return [Object, nil] the transformed value
  def compute_value(object)
    value = object.__send__(name)
    value.nil? and return
    if represent_with
      represent_with.hashify(value)
    elsif value.respond_to?(:iso8601)
      value.extend Betterdocs::JsonTimeWithZone
    else
      sanitizer.sanitize(value)
    end
  end

  # Returns a {Betterdocs::Sanitizer} configured with this
  # property's `sanitize` proc.
  #
  # @return [Betterdocs::Sanitizer]
  def sanitizer
    Betterdocs::Sanitizer.new(&sanitize)
  end

  # Registers this property with the given collector.
  #
  # @param collector [Betterdocs::ResultRepresenterCollector] the target
  def add_to_collector(collector)
    collector.properties[name] = self
  end
end
