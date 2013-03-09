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
      element = build_element(representer, type, name, options, &block)
      case type = type.to_sym
      when :api_property
        @api_properties[element.name] = element
      when :api_link
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

    def to_s
      result = "Representer: #{representer}\n"
      if properties = @api_properties.values.full?
        result << "\nProperties:"
        properties.each_with_object(result) do |property, r|
          r << "\n#{property.name} (#{property.types * '|'}): #{property.description}\n"
        end
      end
      if links = @api_links.values.full?
        result << "\nLinks:"
        links.each_with_object(result) do |link, r|
          r << "\n#{link.name} (#{link.url}) #{link.description}\n"
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
