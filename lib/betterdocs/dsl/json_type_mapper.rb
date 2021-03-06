module Betterdocs::Dsl::JsonTypeMapper
  module_function

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

  def map_types(types)
    if Array === types and types.empty?
      types = [ types ]
    else
      types = Array(types)
    end
    types.map { |t| derive_json_type_from(t) }.uniq.sort
  end
end
