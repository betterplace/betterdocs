module Betterdocs
  class ControllerCollector
    def initialize
      @actions    = {}
      @element    = nil
      @controller = nil
    end

    attr_accessor :controller

    attr_writer :element

    def actions
      @actions.values.reject(&:private)
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
      element.add_to_collector(self)
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
      ([ @controller, '=' * 79, actions * ("-" * 79 + "\n"), '' ]) * "\n"
    end

    private

    def build_element(klass, type, &block)
      Dsl.const_get(type.to_s.camelcase).new(klass, &block)
    end
  end
end
