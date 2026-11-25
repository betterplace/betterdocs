# Naming support for DSL elements. Provides path resolution,
# public name mapping, and full dotted-name generation for
# documentation output.
module Betterdocs::Dsl::Naming
  # Initializes naming state. Sets up the options hash and an
  # empty below-path for nesting.
  def initialize(*)
    super
    @options ||= {}
    @below_path = []
  end

  # @!attribute [r] options
  #   @return [Hash] the element's configuration options
  attr_reader :options

  # Returns the full path of this element, combining any parent
  # path segments with the element's public name.
  #
  # @return [Array<Symbol>] the path segments
  def path
    @below_path + [ public_name ]
  end

  # Returns a shallow copy of this element re-rooted below the
  # given parent path.
  #
  # @param path [Array<Symbol>] the parent path segments
  # @return [self] a duplicated instance with the new below-path
  def below_path(path)
    dup.instance_eval do
      @below_path = path
      self
    end
  end

  # Returns the public-facing name of this element, preferring
  # the `:as` option alias if set.
  #
  # @return [Symbol] the public name
  def public_name
    @options[:as] || name
  end

  # Returns the full dotted name of this element, including any
  # parent path segments.
  #
  # @return [String] e.g. `"parent.child"`
  def full_name
    path * '.'
  end

  # Returns only the parent path segments as a dotted string,
  # excluding this element's own name.
  #
  # @return [String] e.g. `"parent.grandparent"`
  def nesting_name
    @below_path * '.'
  end
end
