module Betterdocs
  module JsonTypeMapper
    module_function

    def derive_json_type_from(klass)
      Class === klass or klass = klass.class
      result = {
        TrueClass  => 'boolean',
        FalseClass => 'boolean',
        NilClass   => 'null',
        Numeric    => 'number',
        Array      => 'array',
        Hash       => 'object',
        String     => 'string',
      }.find { |match_class, json_type|
        match_class >= klass and break json_type
      } || 'undefined'
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
end
