require 'betterdocs/dsl/common'

# Base class for controller DSL elements. Automatically extends
# subclasses with `Tins::DSLAccessor` so they can define
# `dsl_accessor` attributes.
class Betterdocs::Dsl::Controller::ControllerBase
  include Betterdocs::Dsl::Common

  # Extends the subclass with `Tins::DSLAccessor`.
  def self.inherited(klass)
    klass.class_eval { extend Tins::DSLAccessor }
  end

  # Initializes the DSL element with a controller reference and
  # evaluates the given block in the element's context.
  #
  # @param controller [Object] the controller being documented
  def initialize(controller, &block)
    controller(controller)
    set_context controller
    instance_eval(&block)
  end

  # @!method controller
  #
  # @overload controller
  #   Returns the Rails controller being documented.
  #
  #   @note No default; assigned in `initialize`.
  #   @return [Object] the controller being documented
  #
  # @overload controller(controller)
  #   Sets the controller being documented.
  #
  #   @param controller [Object] the controller being documented
  #   @return [Object] the controller being documented
  dsl_accessor :controller

  # Registers this element with the given collector.
  #
  # @param collector [Object] the target collector
  # @raise [NotImplementedError] always, unless overridden
  def add_to_collector(collector)
    raise NotImplementedError, 'add_to_collector needs to be implemented in subclass'
  end
end
