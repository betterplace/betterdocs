module Betterdocs
  module Dsl
    class RepresenterBase
      def initialize(representer, name, options, &block)
        set_context @representer = representer
        @name = name.to_sym
        @options = options | {
          if:      -> { true },
          unless:  -> { false },
        }
        block and instance_eval(&block)
      end

      attr_reader :name

      attr_reader :representer

      def assign?(object)
        object.instance_exec(&(@options[:if])) &&
          !object.instance_exec(&(@options[:unless]))
      end

      def assign(result, object)
        raise NotImplementedError, 'assign needs to be implemented in subclass'
      end

      def add_to_collector(collector)
        raise NotImplementedError, 'add_to_collector needs to be implemented in subclass'
      end
    end

    class Property < RepresenterBase
      extend DSLKit::DSLAccessor
      include Common
      include Naming

      dsl_accessor :represent_with

      dsl_accessor :description, 'TODO'

      dsl_accessor :example, 'TODO'

      dsl_accessor :types do [] end

      def initialize(representer, name, options, &block)
        super
        types JsonTypeMapper.map_types(types)
        if sr = sub_representer?
          sr < Betterdocs::Representer or
            raise TypeError, "#{sr.inspect} is not a Betterdocs::Representer subclass"
        end
      end

      def sub_representer?
        represent_with
      end

      def actual_property_name
        (options[:as] || name).to_s
      end

      def assign(result, object)
        assign?(object) or return
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

      def add_to_collector(collector)
        collector.properties[name] = self
      end
    end

    class CollectionProperty < Property
      def value(object)
        object.__send__(name).to_a.compact.map do |v|
          represent_with.hashify(v)
        end
      end
    end

    class Link < RepresenterBase
      extend DSLKit::DSLAccessor
      include Common
      include Naming

      dsl_accessor :description, 'TODO'

      dsl_accessor :templated, false

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
        assign?(object) or return
        link = {
          'rel'  => name.to_s,
          'href' => object.instance_eval(&url).to_s,
        }
        templated and link['templated'] = true
        result['links'].push(link)
      end

      def add_to_collector(collector)
        collector.links[name] = self
      end
    end
  end
end
