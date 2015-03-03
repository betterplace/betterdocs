module Betterdocs
  module Dsl
    module Common
      include Tins::To
      extend Tins::Constant

      constant :yes, true

      constant :no,  false

      def set_context(context)
        @__context__ = context
        self
      end

      private

      def method_missing(name, *a, &b)
        if @__context__
          @__context__.__send__(name, *a, &b)
        else
          super
        end
      end
    end
  end
end
