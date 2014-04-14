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

    def add_element(representer, type, name, options = {}, &block)
      case type = type.to_sym
      when :property, :collection_property
        element = build_element(representer, type, name, options, &block)
        @properties[element.name] = element
      when :link
        element = build_element(representer, type, name, &block)
        @links[element.name] = element
      else
        raise ArgumentError, "invalid documentation element type #{type.inspect}"
      end
    end

    def representer
      (@properties.values + @links.values).find { |v|
        v.representer and break v.representer
      }
    end

    def nested_properties(path = [])
      properties.values.each_with_object([]) do |property, result|
        result << property.below_path(path)
        if sr = property.sub_representer?
          result.concat sr.docs.nested_properties(path + property.path)
        end
      end
    end

    def nested_links(path = [])
      result = links.values.map { |l| l.below_path(path) }
      properties.values.each_with_object(result) do |property, result|
        if sr = property.sub_representer?
          nested_property = property.below_path(path)
          links = sr.docs.nested_links(nested_property.path)
          result.concat links
        end
      end
      result
    end

    def to_s
      result = "*** #{representer} ***\n"
      if properties = @properties.values.full?
        result << "\nProperties:"
        nested_properties.each_with_object(result) do |property, r|
          r << "\n#{property.full_name}: (#{property.types * '|'}): #{property.description}\n"
        end
      end
      if links = @links.values.full?
        result << "\nLinks:"
        links.each_with_object(result) do |link, r|
          r << "\n#{link.full_name}: #{link.description}\n" # TODO resolve link.url in some useful way
        end
      end
      result
    end

    private

    def build_element(representer, type, *args, &block)
      begin
        element = Dsl.const_get(type.to_s.camelcase)
      rescue NameError => e
        raise ArgumentError, "unknown documentation element type #{type.inspect}"
      end
      element.new(representer, *args, &block)
    end
  end
end
