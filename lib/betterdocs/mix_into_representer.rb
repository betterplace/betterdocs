module Betterdocs
  module MixIntoRepresenter
    extend ActiveSupport::Concern

    module ClassMethods
      def doc(type, &block)
        warn "doc #{type.inspect} wasn't implemented yet"
        docs.configure_current_element(name)
      end

      def docs
        @docs ||= Collector.new
      end

      def property(*)
        p :property
        super
      end

      def link(*)
        p :link
        super
      end
    end
  end
end
