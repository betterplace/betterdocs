module Betterdocs::JsonParamsRepresenter
  extend ActiveSupport::Concern
  include Betterdocs::Representer

  module ClassMethods
    def build_result_object
      ActionController::Parameters.new
    end

    def hashify(object)
      super do |result|
        assign_params result, object
      end
    end

    def docs
      @docs ||= Betterdocs::JsonParamsRepresenterCollector.new
    end

    def assign_params(result, object)
      for param in params
        param.assign(result, object)
      end
    end
    private :assign_params

    def params
      @params ||= Set.new
    end

    def param(name, **options, &block)
      d = doc(:param, name, **options, &block) and
        params << d
      self
    end
  end
end
