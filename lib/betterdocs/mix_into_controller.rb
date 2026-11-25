module Betterdocs
  # Concern that mixes the Betterdocs DSL into a Rails controller class.
  # Registers a {ControllerCollector} per controller and hooks `doc`
  # blocks into it; `method_added` finalizes the element in progress
  # whenever a new controller method is defined.
  module MixIntoController
    extend ActiveSupport::Concern

    # Methods `extend`ed onto the controller class via `ActiveSupport::Concern`.
    module ClassMethods
      # Finalizes the documentation element in progress, binding it to
      # the controller method that was just defined.
      #
      # @param name [Symbol] the name of the newly added method
      def method_added(name)
        docs.configure_current_element(name)
      end

      # Opens a documentation element of the given type for this
      # controller, evaluating the block in the DSL context.
      #
      # @param type [Symbol] the element type (`:action`)
      # @yield the DSL block for the element
      def doc(type, &block)
        docs.add_element(self, type, &block)
      end

      # Returns the {ControllerCollector} for this controller, lazily
      # created on first access.
      #
      # @return [Betterdocs::ControllerCollector] the collector
      def docs
        @docs ||= ControllerCollector.new
      end
    end
  end
end
