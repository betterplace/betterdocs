module Betterdocs
  module Dsl
    # Shared DSL base module. Provides `yes`/`no` constants and
    # context delegation via `method_missing`. Included by all
    # documentation elements.
    module Common
      extend Tins::Constant

      # Boolean constant representing a required or affirmative value.
      constant :yes, true

      # Boolean constant representing an optional or negated value.
      constant :no,  false

      # Sets the delegation context for subsequent DSL calls.
      #
      # @param context [Object] the object to delegate unknown
      #   method calls to
      # @return [self]
      def set_context(context)
        @__context__ = context
        self
      end

      private

      # Forwards unrecognized method calls to the delegation context.
      # Falls through to the default `method_missing` when no context
      # has been set.
      #
      # @param name [Symbol] the method name to delegate
      # @param a [Array] positional arguments
      # @param b [Proc] optional block
      # @return [Object] the return value of the delegated call
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
