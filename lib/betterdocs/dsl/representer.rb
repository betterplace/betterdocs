# Base class for all DSL documentation elements (params, properties,
# links, etc.). Stores the parent representer, element name, and
# options, and provides conditional inclusion logic via `if`/`unless`
# blocks.
class Betterdocs::Dsl::Representer
  # Initializes a documentation element.
  #
  # @param representer [Module] the parent representer
  # @param name [Symbol] the name of the element
  # @param options [Hash] configuration options; supports `:if` and
  #   `:unless` blocks for conditional inclusion
  # @yield Evaluates the DSL block in the context of this element
  def initialize(representer, name, options, &block)
    set_context @representer = representer
    @name = name.to_sym
    @options = options | {
      if:      -> { true },
      unless:  -> { false },
    }
    block and instance_eval(&block)
  end

  # @!attribute [r] name
  #   @return [Symbol] the element name
  attr_reader :name

  # @!attribute [r] representer
  #   @return [Module] the parent representer
  attr_reader :representer

  # Determines whether this element should be assigned for the given
  # object, based on the `:if` and `:unless` option blocks.
  #
  # @param object [Object] the response object
  # @return [Boolean] true if the element should be included
  def assign?(object)
    object.instance_exec(&@options[:if]) &&
      !object.instance_exec(&@options[:unless])
  end

  # Assigns the element's value to the result hash.
  #
  # @param result [Hash] the result container
  # @param object [Object] the source object
  # @raise [NotImplementedError] always, unless overridden in a
  #   subclass
  def assign(result, object)
    raise NotImplementedError, 'assign needs to be implemented in subclass'
  end

  # Registers this element with the given collector.
  #
  # @param collector [Object] the collector to register with
  # @raise [NotImplementedError] always, unless overridden in a
  #   subclass
  def add_to_collector(collector)
    raise NotImplementedError, 'add_to_collector needs to be implemented in subclass'
  end
end
