# Represents a single request parameter for a controller action.
class Betterdocs::Dsl::Controller::Action::Param
  extend Tins::DSLAccessor
  include ::Betterdocs::Dsl::Common

  # Initializes the param with a name and evaluates the block for
  # DSL configuration.
  #
  # @param param_name [Symbol] the parameter name
  def initialize(param_name, &block)
    name param_name
    block and instance_eval(&block)
  end

  # @!method name
  #
  # @overload name
  #   Returns the name of this request parameter.
  #
  #   @note No default; assigned in `initialize`.
  #   @return [Symbol] the parameter name
  #
  # @overload name(name)
  #   Sets the parameter name.
  #
  #   @param name [Symbol] the parameter name
  #   @return [Symbol] the parameter name
  dsl_accessor :name

  # @!method value
  #
  # @overload value
  #   Returns the example value shown for this parameter.
  #
  #   @note Returns `nil` until set.
  #   @return [Object] the parameter's example value
  #
  # @overload value(value)
  #   Sets the example value.
  #
  #   @param value [Object] the example value
  #   @return [Object] the example value
  dsl_accessor :value

  # @!method required
  #
  # @overload required
  #   Returns whether this parameter is required in the request.
  #
  #   @note Defaults to `true`.
  #   @return [Boolean] whether the parameter is required
  #
  # @overload required(flag)
  #   Sets whether the parameter is required.
  #
  #   @param flag [Boolean] whether the parameter is required
  #   @return [Boolean] whether the parameter is required
  dsl_accessor :required, true

  # @!method description
  #
  # @overload description
  #   Returns the human-readable description of this parameter.
  #
  #   @note Defaults to `"TODO"`.
  #   @return [String] the parameter description
  #
  # @overload description(description)
  #   Sets the parameter description.
  #
  #   @param description [String] the description
  #   @return [String] the description
  dsl_accessor :description, 'TODO'

  # @!method use_in_url
  #
  # @overload use_in_url
  #   Returns whether this parameter's value is used to construct an
  #   example URL. Also exposed as the `use_in_url?` predicate.
  #
  #   @note Defaults to `true`.
  #   @return [Boolean] whether the value is used in example URLs
  #
  # @overload use_in_url(flag)
  #   Sets whether the value is used to construct an example URL.
  #
  #   @param flag [Boolean] the flag
  #   @return [Boolean] the flag
  dsl_accessor :use_in_url, true

  alias use_in_url? use_in_url

  # Returns the string representation of the param's value.
  #
  # @return [String]
  def to_s
    value.to_s
  end
end
