require 'action_controller'
require 'betterdocs/responding'

# Base representer concern providing JSON serialization via `as_json`,
# `to_hash`, and `to_json`. Include in a module that also declares
# documentation elements via the {ClassMethods} DSL.
module Betterdocs::Representer
  extend ActiveSupport::Concern

  # Serializes the object to a JSON-compatible Hash by walking the
  # singleton class ancestor chain to find the first ancestor that
  # includes {Betterdocs::Representer}, then delegating to its
  # {ClassMethods#hashify}.
  #
  # @return [Hash] the serialized result
  def as_json(*)
    singleton_class.ancestors.find do |c|
      c != singleton_class && c < Betterdocs::Representer
    end.hashify(self)
  end

  # Alias for {#as_json}.
  alias to_hash as_json

  # Serializes the object to a JSON string.
  #
  # @param a [Array] additional arguments passed through to
  #   `JSON.generate`
  # @return [String] the JSON representation
  def to_json(*a)
    JSON::generate(as_json, *a)
  end

  # Methods `extend`ed onto the including class via
  # `ActiveSupport::Concern`: applies the representer, builds the
  # result container, registers docs, and resolves the collector.
  module ClassMethods
    # Extends the given object with this representer module.
    #
    # @param object [Object] the object to decorate
    def apply(object)
      object.extend self
    end

    # Returns the base container for the serialized result.
    #
    # @return [Hash] an empty Hash
    def build_result_object
      {}
    end

    # Applies the representer to +object+ and builds the result by
    # yielding the container to the given block.
    #
    # @param object [Object] the object to serialize
    # @yieldparam result [Hash] the container to populate
    # @return [Hash] the serialized result
    def hashify(object, &block)
      apply(object)
      result = build_result_object
      instance_exec(result, &block)
      result
    end

    # Registers a documentation element with the {#docs} collector.
    #
    # @param type [Symbol] the element type (e.g. `:param`, `:property`)
    # @param name [Symbol] the name of the element
    # @param options [Hash] additional options forwarded to the element
    # @return [Betterdocs::Dsl::Representer] the registered element
    def doc(type, name, **options, &block)
      docs.add_element(self, type, name, **options, &block)
    end

    # Returns the name of the represented object. Override in
    # subclasses that need a custom object name in the documentation.
    def object_name(*) end

    # Returns the documentation collector for this representer.
    # Must be implemented in the including module.
    #
    # @raise [NotImplementedError] always, unless overridden
    def docs
      raise NotImplementedError, 'has to be implemented in including module'
    end
  end
end
