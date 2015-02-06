require 'betterdocs/dsl/representer/representer_base'
require 'betterdocs/dsl/representer/json_type_mapper'
require 'betterdocs/dsl/common'
require 'betterdocs/dsl/naming'

class Betterdocs::Dsl::Representer::Property < Betterdocs::Dsl::Representer::RepresenterBase
  extend Tins::DSLAccessor
  include Betterdocs::Dsl::Common
  include Betterdocs::Dsl::Naming

  dsl_accessor :represent_with

  dsl_accessor :description, 'TODO'

  dsl_accessor :example, 'TODO'

  dsl_accessor :types do [] end

  def initialize(representer, name, options, &block)
    super
    types Betterdocs::Dsl::Representer::JsonTypeMapper.map_types(types)
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
