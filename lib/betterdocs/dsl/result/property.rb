require 'betterdocs/dsl/representer'
require 'betterdocs/dsl/common'
require 'betterdocs/dsl/naming'
require 'betterdocs/dsl/json_type_mapper'

class Betterdocs::Dsl::Result::Property < Betterdocs::Dsl::Representer
  extend Tins::DSLAccessor
  include Betterdocs::Dsl::Common
  include Betterdocs::Dsl::Naming

  dsl_accessor :represent_with

  dsl_accessor :description, 'TODO'

  dsl_accessor :example, 'TODO'

  dsl_accessor :types do [] end

  def initialize(representer, name, options, &block)
    super
    types Betterdocs::Dsl::JsonTypeMapper.map_types(types)
    if sr = sub_representer?
      sr < Betterdocs::ResultRepresenter or
        raise TypeError, "#{sr.inspect} is not a Betterdocs::Result subclass"
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
    result[actual_property_name] = compute_value(object)
  end

  def compute_value(object)
    value = object.__send__(name)
    value.nil? and return
    if represent_with
      represent_with.hashify(value)
    elsif ActiveSupport::TimeWithZone === value
      value.extend Betterdocs::JsonTimeWithZone
    else
      value
    end
  end

  def add_to_collector(collector)
    collector.properties[name] = self
  end
end
