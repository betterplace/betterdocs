module Betterdocs
  module Dsl
    class ApiProperty
      extend DSLKit::DSLAccessor
      include Common
      include Naming

      dsl_accessor :representer

      dsl_accessor :represent_with

      dsl_accessor :description, 'TODO'

      dsl_accessor :example, 'TODO'

      dsl_accessor :types do [] end

      attr_reader :name

      attr_reader :options

      def initialize(representer, name, options, &block)
        @representer = representer
        set_context @representer
        @name = name.to_sym
        @options = options
        block and instance_eval(&block)
        types JsonTypeMapper.map_types(types)
        if sr = sub_representer?
          sr < Betterdocs::Representer or
            raise TypeError, "#{sr.inspect} is not a Betterdocs::Representer subclass"
          @options[:represent_with] = sr
        end
        super
      end

      def sub_representer?
        represent_with
      end
    end

    class ApiLink
      extend DSLKit::DSLAccessor
      include Common
      include Naming

      attr_reader :name

      dsl_accessor :representer

      dsl_accessor :description, 'TODO'

      def initialize(representer, name, &block)
        @representer = representer
        set_context @representer
        @name = name.to_sym
        block and instance_eval(&block)
        super
      end

      def url(&block)
        if block
          @url = block
        elsif @url
          @url
        else
          raise ArgumentError, 'link requires an URL'
        end
      end
    end
  end
end
