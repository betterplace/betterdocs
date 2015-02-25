class Betterdocs::Dsl::Controller::Action::Param
  extend Tins::DSLAccessor
  include ::Betterdocs::Dsl::Common

  def initialize(param_name, &block)
    name param_name
    block and instance_eval(&block)
  end

  dsl_accessor :name

  dsl_accessor :value

  dsl_accessor :required, true

  dsl_accessor :description, 'TODO'

  dsl_accessor :use_in_url, true

  alias use_in_url? use_in_url

  def to_s
    value
  end
end
