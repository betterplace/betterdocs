module Betterdocs
  module MixIntoController
    extend ActiveSupport::Concern

    module ClassMethods
      def method_added(name)
        docs.configure_current_element(name)
      end

      def doc(type, &block)
        docs.add_element(self, type, &block)
      end

      def docs
        @docs ||= ControllerCollector.new
      end
    end
  end
end
