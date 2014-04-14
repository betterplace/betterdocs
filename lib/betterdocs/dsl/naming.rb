module Betterdocs
  module Dsl
    module Naming
      def initialize(*)
        @options ||= {}
        @below_path = []
      end

      def path
        @below_path + [ public_name ]
      end

      def below_path(path = nil)
        if path
          dup.instance_eval do
            @below_path = path
            self
          end
        else
          @below_path
        end
      end

      def public_name
        @options[:as] || name
      end

      def full_name
        path * '.'
      end

      def nesting_name
        below_path * '.'
      end
    end
  end
end
