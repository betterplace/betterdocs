module Betterdocs
  # Collects and manages documentation elements (actions, params,
  # responses) for a single controller's `doc` block.
  class ControllerCollector
    # Initializes an empty collector.
    def initialize
      @actions    = {}
      @element    = nil
      @controller = nil
    end

    # The controller class being documented.
    #
    # @return [Class, nil] the controller class
    attr_accessor :controller

    # The currently in-progress documentation element.
    attr_writer :element

    # Returns all non-private actions in insertion order.
    #
    # @return [Array<Betterdocs::Dsl::Controller::Action>]
    def actions
      @actions.values.reject(&:private)
    end

    # Looks up a single action by name.
    #
    # @param action_name [String, Symbol] the action name
    # @return [Betterdocs::Dsl::Controller::Action, nil]
    def action(action_name)
      action_name = action_name.to_sym
      @actions[action_name]
    end

    # Returns the section identifier by delegating to the documented
    # {Betterdocs::Dsl::Controller::Controller} element's `#section`,
    # if it responds.
    #
    # @return [Symbol, nil] the section identifier
    def section
      @controller.ask_and_send(:section)
    end

    # Builds a documentation element of the given type and registers
    # it with this collector.
    #
    # @param klass [Class] the controller class being documented
    # @param type [Symbol] the element type
    # @yield documentation block for the element
    def add_element(klass, type, &block)
      element = build_element(klass, type, &block)
      element.add_to_collector(self)
    end

    # Finalizes the current element by configuring it for the named
    # action and storing it, then clears the element slot.
    #
    # @param action_name [Symbol] the action to associate
    # @return [self]
    def configure_current_element(action_name)
      if @element
        @element.configure_for_action(action_name)
        @actions[action_name] = @element
      end
      @element = nil
      self
    end

    # Renders a human-readable text summary of the controller and
    # its actions.
    #
    # @return [String]
    def to_s
      ([ @controller, '=' * 79, actions * ("-" * 79 + "\n"), '' ]) * "\n"
    end

    private

    # Instantiates the appropriate `Dsl::Controller` subclass for
    # the given type string.
    #
    # @param klass [Class] the controller class being documented
    # @param type [Symbol] the element type
    # @yield documentation block for the element
    # @return [Betterdocs::Dsl::Controller::Action]
    def build_element(klass, type, &block)
      Dsl::Controller.const_get(type.to_s.camelcase).new(klass, &block)
    end
  end
end
