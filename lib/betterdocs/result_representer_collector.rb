module Betterdocs
  # Collects and renders the documentation elements (properties and links)
  # that belong to a result representer. Used by the generators to produce
  # human-readable output of a representer's documented fields.
  class ResultRepresenterCollector
    # Initializes an empty collector with no properties or links.
    def initialize
      @properties = {}
      @links      = {}
    end

    # @!attribute [r] properties
    #   @return [Hash{Symbol => Betterdocs::Dsl::Result::Property}] all
    #     registered properties keyed by name
    attr_reader :properties

    # @!attribute [r] links
    #   @return [Hash{Symbol => Betterdocs::Dsl::Result::Link}] all
    #     registered links keyed by name
    attr_reader :links

    # Returns the property registered under +property_name+.
    #
    # @param property_name [Symbol, String] the property name
    # @return [Betterdocs::Dsl::Result::Property, nil] the property, or
    #   `nil` if not registered
    def property(property_name)
      property_name = property_name.to_sym
      @properties[property_name]
    end

    # Returns the link registered under +link_name+.
    #
    # @param link_name [Symbol, String] the link name
    # @return [Betterdocs::Dsl::Result::Link, nil] the link, or `nil` if
    #   not registered
    def link(link_name)
      link_name = link_name.to_sym
      @links[link_name]
    end

    # Builds a documentation element of the given +type+ and registers it
    # in this collector.
    #
    # @param representer [Module] the representer that owns this element
    # @param type [Symbol] the element type (e.g. `:property`, `:link`)
    # @param name [Symbol] the name of the element
    # @param options [Hash] additional options forwarded to the element
    # @raise [ArgumentError] if +type+ does not map to a known element
    def add_element(representer, type, name, **options, &block)
      element = build_element(representer, type, name, options, &block)
      element.add_to_collector(self)
    end

    # Returns the name of the first element that carries a representer
    # reference.
    #
    # @return [String, nil] the representer name, or `nil` if no element
    #   has one
    def representer
      (@properties.values + @links.values).find { |v|
        v.representer and break v.representer
      }
    end

    # Flattens all properties (including those nested in sub-representers)
    # into a single array, adjusted for the given +path+.
    #
    # @param path [Array] the current nesting path for path adjustment
    # @return [Array<Betterdocs::Dsl::Result::Property>] all properties,
    #   including nested ones
    def nested_properties(path = [])
      properties.values.each_with_object([]) do |property, result|
        result << property.below_path(path)
        if sr = property.sub_representer?
          result.concat sr.docs.nested_properties(path + property.path)
        end
      end
    end

    # Flattens all links (including those nested in sub-representers)
    # into a single array, adjusted for the given +path+.
    #
    # @param path [Array] the current nesting path for path adjustment
    # @return [Array<Betterdocs::Dsl::Result::Link>] all links, including
    #   nested ones
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

    # Renders a human-readable summary of all documented properties and
    # links.
    #
    # @return [String] the formatted documentation
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

    # Instantiates the DSL element class corresponding to +type+ under
    # `Betterdocs::Dsl::Result`.
    #
    # @param representer [Module] the owning representer
    # @param type [Symbol] the element type to look up
    # @param args [Array] additional arguments forwarded to the element
    #   constructor
    # @raise [ArgumentError] if +type+ does not resolve to a class
    # @return [Betterdocs::Dsl::Representer] the instantiated element
    def build_element(representer, type, *args, &block)
      begin
        element = Dsl::Result.const_get(type.to_s.camelcase)
      rescue NameError
        raise ArgumentError, "unknown documentation element type #{type.inspect}"
      end
      element.new(representer, *args, &block)
    end
  end
end
