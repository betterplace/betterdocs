require 'dslkit/polite'

module Betterdocs
  module Dsl
    module Truthiness
      extend DSLKit::Constant

      constant :yes, true

      constant :no,  false
    end

    class Controller
      extend DSLKit::DSLAccessor

      def initialize(controller, &block)
        @controller = controller
        instance_eval(&block)
      end

      dsl_accessor :controller

      alias name controller

      dsl_accessor :section

      dsl_accessor :description, 'TODO'

      def url
        Rails.application.routes.url_for(
          { controller: controller.name.underscore.sub(/_controller\z/, ''), action: :index }
        )
      end

      def to_s
        [ controller, '', "url: #{url}", '', description, '' ] * "\n"
      end
    end

    class Action < Controller
      extend DSLKit::DSLAccessor

      dsl_accessor :action

      alias name action

      dsl_accessor :section do
        controller.docs.controller.section || :misc
      end

      dsl_accessor :action_method

      dsl_accessor :http_method do
        case action
        when :show, :index
          :GET
        when :update
          :PUT
        when :destroy
          :DELETE
        when :create
          :POST
        end
      end

      dsl_accessor :params do {} end

      class Param
        extend DSLKit::DSLAccessor
        include ::Betterdocs::Dsl::Truthiness # XXX improve the namespacing

        def initialize(param_name, &block)
          name param_name
          block and instance_eval(&block)
        end

        dsl_accessor :name

        dsl_accessor :value

        dsl_accessor :optional, false

        def required(value = nil)
          if value.nil?
            !optional
          else
            optional !value
          end
        end

        dsl_accessor :description, 'TODO'

        def to_s
          value
        end
      end

      def param(name, &block)
        param = Param.new(name, &block)
        param.value or param.value params.size + 1
        params[name] = param
      end

      dsl_accessor :description, 'TODO'

      def configure_for_action(action_name)
        action action_name
        action_method controller.instance_method(action_name)
      end

      def url
        Betterplace::Application.routes.url_for(
          { controller: controller.name.underscore.sub(/_controller\z/, ''), action: action } | params
        )
      end

      def request
        "#{http_method} #{url}"
      end

      def to_s
        (
          [ request, '' ] +
          [ inspect, '' ] +
          params.map { |name, param| "#{name}(=#{param.value}): #{param.description}" } +
          [ '', description, '', action_method.source_location * ':', '' ]) * "\n"
      end

      def inspect
        "#{controller}##{action}(#{params.keys * ', '})"
      end
    end
  end
end
