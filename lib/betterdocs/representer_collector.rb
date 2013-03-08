module Betterdocs
  class RepresenterCollector
    def initialize
      @properties = {}
      @links      = {}
    end

    attr_reader :properties

    attr_reader :links

    def property(property_name)
      property_name = property_name.to_sym
      @properties[property_name]
    end

    def link(link_name)
      link_name = link_name.to_sym
      @links[link_name]
    end

    def add_element(klass, type, name, options = {}, &block)
      element = build_element(klass, type, name, options, &block)
      case type = type.to_sym
      when :property
        @properties[element.name] = element
      when :link
        @links[element.name] = element
      else
        raise ArgumentError, "unkown documentation element type #{type.inspect}"
      end
      self
    end

    def to_s
      'TODO'
    end

    private

    def build_element(klass, type, *args, &block)
      klass = Dsl.const_get(type.to_s.camelcase)
      klass.new(*args, &block)
    end
  end
end
