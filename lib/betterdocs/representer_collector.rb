module Betterdocs
  class RepresenterCollector
    def initialize
      @api_properties = {}
      @api_links      = {}
    end

    attr_reader :api_properties

    attr_reader :api_links

    def api_property(property_name)
      property_name = property_name.to_sym
      @api_properties[property_name]
    end

    def api_link(link_name)
      link_name = link_name.to_sym
      @api_links[link_name]
    end

    def add_element(representer, type, name, options = {}, &block)
      case type = type.to_sym
      when :api_property
        element = build_element(representer, type, name, options, &block)
        @api_properties[element.name] = element
      when :api_link
        element = build_element(representer, type, name, &block)
        @api_links[element.name] = element
      else
        raise ArgumentError, "invalid documentation element type #{type.inspect}"
      end
      self
    end

    def representer
      (@api_properties.values + @api_links.values).find { |v|
        v.representer and break v.representer
      }
    end

    def nested_api_properties(path = [])
      api_properties.values.each_with_object([]) do |property, result|
        if sr = property.sub_representer?
          result.concat sr.docs.nested_api_properties(path + property.path)
        else
          result << property.below_path(path)
        end
      end
    end

    def nested_api_links(path = [])
      result = []
      result += api_links.values.map { |l| l.below_path(path) }
      api_properties.values.each_with_object(result) do |property, result|
        if sr = property.sub_representer?
          result.concat sr.docs.nested_api_links(path + property.path)
        end
      end
      result
    end

    def to_s
      result = "*** #{representer} ***\n"
      if properties = @api_properties.values.full?
        result << "\nProperties:"
        nested_api_properties.each_with_object(result) do |property, r|
          r << "\n#{property.full_name}: (#{property.types * '|'}): #{property.description}\n"
        end
      end
      if links = @api_links.values.full?
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
