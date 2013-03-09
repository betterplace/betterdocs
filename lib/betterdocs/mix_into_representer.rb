module Betterdocs
  module MixIntoRepresenter
    extend ActiveSupport::Concern

    module ClassMethods
      def doc(type, name, options = {}, &block)
        docs.add_element(self, type, name, options, &block)
      end

      def api_property(name, options = {}, &block)
        doc :api_property, name, options, &block
        docs.api_property(name).define
      end

      def api_link(name, options = {}, &block)
        doc :api_link, name, options, &block
        docs.api_link(name).define
      end

      def docs
        @docs ||= RepresenterCollector.new
      end
    end
  end
end
