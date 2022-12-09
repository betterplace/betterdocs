require 'action_controller'
require 'betterdocs/responding'

module Betterdocs::Representer
  include Betterdocs::Responding
  extend ActiveSupport::Concern

  def as_json(*)
    singleton_class.ancestors.find do |c|
      c != singleton_class && c < Betterdocs::Representer
    end.hashify(self)
  end

  alias to_hash as_json

  def to_json(*a)
    JSON::generate(as_json, *a)
  end

  module ClassMethods
    def apply(object)
      object.extend self
    end

    def build_result_object
      {}
    end

    def hashify(object, &block)
      apply(object)
      result = build_result_object
      instance_exec(result, &block)
      result
    end

    def doc(type, name, **options, &block)
      docs.add_element(self, type, name, **options, &block)
    end

    def object_name(*) end

    def docs
      raise NotImplementedError, 'has to be implemented in including module'
    end
  end
end
