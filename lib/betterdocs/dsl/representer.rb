module Betterdocs
  module Dsl
    class Property
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
        @as = options[:as]
        set_context @representer = representer
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

      def actual_property_name
        (@as || name).to_s
      end

      def assign(result, object)
        result[actual_property_name] = value(object)
      end

      def value(object)
        value = object.__send__(name)
        if !value.nil? && represent_with
          represent_with.hashify(value)
        else
          value
        end
      end
    end

    class CollectionProperty < Property
      def value(object)
        object.__send__(name).to_a.compact.map do |v|
          represent_with.hashify(v)
        end
      end
    end

    class Link
      extend DSLKit::DSLAccessor
      include Common
      include Naming

      attr_reader :name

      dsl_accessor :representer

      dsl_accessor :description, 'TODO'

      def initialize(representer, name, &block)
        set_context @representer = representer
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

      def assign(result, object)
        result['links'].push(
          'rel'  => name.to_s,
          'href' => object.instance_eval(&url).to_s,
        )
      end
    end
  end
end
