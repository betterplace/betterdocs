require 'betterdocs/dsl/representer'
require 'betterdocs/dsl/common'
require 'betterdocs/dsl/naming'

# A documented HAL-style link in an API response. Extends
# {Betterdocs::Dsl::Representer} with a URL block and optional
# templated flag.
class Betterdocs::Dsl::Result::Link < Betterdocs::Dsl::Representer
  extend Tins::DSLAccessor
  include Betterdocs::Dsl::Common
  include Betterdocs::Dsl::Naming

  # @!method description
  #
  # @overload description
  #   Returns the human-readable description of the link.
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

  # @!method templated
  #
  # @overload templated
  #   Returns whether the link URL is templated (contains variables).
  #
  #   @note Defaults to `false`.
  #   @return [Boolean] whether the link is templated
  #
  # @overload templated(flag)
  #   Sets whether the link is templated.
  #
  #   @param flag [Boolean] the flag
  #   @return [Boolean] the flag
  dsl_accessor :templated, false

  # Sets or returns the URL block for this link.
  #
  # @param block [Proc, nil] a block that returns the URL string;
  #   nil to read the current block
  # @raise [ArgumentError] if called without a block and no URL is set
  # @return [Proc, nil] the stored URL block (when reading)
  def url(&block)
    if block
      @url = block
    elsif @url
      @url
    else
      raise ArgumentError, 'link requires an URL'
    end
  end

  # Builds the HAL link hash and appends it to `result['links']`.
  #
  # @param result [Hash] the target result hash (must have a 'links' key)
  # @param object [Object] the source object to evaluate the URL block on
  def assign(result, object)
    assign?(object) or return
    link = {
      'rel'  => name.to_s,
      'href' => object.instance_eval(&url).to_s,
    }
    templated and link['templated'] = true
    result['links'].push(link)
    self
  end

  # Registers this link with the given collector.
  #
  # @param collector [Betterdocs::ResultRepresenterCollector] the target
  def add_to_collector(collector)
    collector.links[name] = self
  end
end
