# Maps Ruby classes to their JSON type equivalents for OpenAPI
# schema generation.
module Betterdocs::Dsl::JsonTypeMapper
  module_function

  # Derives the JSON type string for a given Ruby class or value.
  #
  # @param klass [Class, Object] a Ruby class or instance to
  #   derive the type from
  # @return [String] the JSON type name (`"string"`, `"number"`,
  #   `"boolean"`, etc.)
  # @raise [TypeError] if the class cannot be mapped to a JSON type
  def derive_json_type_from(klass)
    Class === klass or klass = klass.class
    {
      TrueClass  => 'boolean',
      FalseClass => 'boolean',
      NilClass   => 'null',
      Numeric    => 'number',
      Array      => 'array',
      Hash       => 'object',
      String     => 'string',
    }.find { |match_class, json_type|
      match_class >= klass and break json_type
    } or raise TypeError, "Invalid type #{klass} encountered. Use a type that can be mapped to JSON instead."
  end

  # Maps one or more Ruby types to a sorted, unique array of JSON
  # type names.
  #
  # @param types [Class, Array<Class>] one or more Ruby classes
  # @return [Array<String>] sorted unique JSON type names
  def map_types(types)
    if Array === types and types.empty?
      types = [ types ]
    else
      types = Array(types)
    end
    types.map { |t| derive_json_type_from(t) }.uniq.sort
  end
end
