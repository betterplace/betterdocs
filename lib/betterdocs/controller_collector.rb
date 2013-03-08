module Betterdocs
  class ControllerCollector
    def initialize
      @actions    = {}
      @element    = nil
      @controller = nil
    end

    attr_reader :controller

    def actions
      @actions.values
    end

    def action(action_name)
      action_name = action_name.to_sym
      @actions[action_name]
    end

    def section
      @controller.ask_and_send(:section)
    end

    def add_element(klass, type, &block)
      element = build_element(klass, type, &block)
      case type = type.to_sym
      when :controller
        @controller = element
      when :action
        @element = element
      else
        raise ArgumentError, "unkown documentation element type #{type.inspect}"
      end
      self
    end

    def configure_current_element(action_name)
      if @element
        @element.configure_for_action(action_name)
        @actions[action_name] = @element
      end
      @element = nil
      self
    end

    def to_s
      ([ @controller, '=' * 79, @actions.values * ("-" * 79 + "\n"), '' ]) * "\n"
    end

    private

    def build_element(klass, type, &block)
      Dsl.const_get(type.to_s.camelcase).new(klass, &block)
    end
  end
end
