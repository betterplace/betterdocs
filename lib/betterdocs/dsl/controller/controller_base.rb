require 'betterdocs/dsl/common'

class Betterdocs::Dsl::Controller::ControllerBase
  include Betterdocs::Dsl::Common

  def self.inherited(klass)
    klass.class_eval { extend Tins::DSLAccessor }
  end

  def initialize(controller, &block)
    controller(controller)
    set_context controller
    instance_eval(&block)
  end

  dsl_accessor :controller

  def add_to_collector(collector)
    raise NotImplementedError, 'add_to_collector needs to be implemented in subclass'
  end
end
