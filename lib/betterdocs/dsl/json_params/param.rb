require 'betterdocs/dsl/naming'

class Betterdocs::Dsl::JsonParams::Param < Betterdocs::Dsl::Representer
  extend Tins::DSLAccessor
  include Betterdocs::Dsl::Common
  include Betterdocs::Dsl::Naming

  dsl_accessor :description, 'TODO'

  dsl_accessor :value, 'TODO'

  dsl_accessor :types do [] end

  dsl_accessor :required, true

  def initialize(representer, name, options, &block)
    super
    types Betterdocs::Dsl::JsonTypeMapper.map_types(types)
  end

  def assign(result, object)
    assign?(object) or return
    result[name] = compute_value(object)
  end

  def compute_value(object)
    value = object.__send__(name)
    value.respond_to?(:iso8601) and value.extend Betterdocs::JsonTimeWithZone
    value
  end

  def add_to_collector(collector)
    collector.params[name] = self
  end
end
