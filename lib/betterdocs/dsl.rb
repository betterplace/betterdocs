require 'dslkit/polite'
require 'tins/xt/to'

module Betterdocs
  module Dsl
    module Common
      extend DSLKit::Constant

      constant :yes, true

      constant :no,  false
    end

    class Controller
      extend DSLKit::DSLAccessor
      include Common

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
          {
            controller: controller.name.underscore.sub(/_controller\z/, ''),
            action: :index,
            format: 'api_json',
          } | Betterdocs::Global.config.api_url_options
        )
      end

      def to_s
        [ controller, '', "url: #{url}", '', description, '' ] * "\n"
      end
    end

    class Action < Controller
      extend DSLKit::DSLAccessor
      include Common

      dsl_accessor :action

      alias name action


      dsl_accessor :title

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
        include ::Betterdocs::Dsl::Common

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

      dsl_accessor :responses do {} end

      class Response
        extend DSLKit::DSLAccessor

        def initialize(name = :default, &block)
          @name = name.to_sym
          #provide_factories
          @data_block = block || proc {}
        end

        dsl_accessor :name

        def data
          @data ||= instance_eval(&@data_block)
        end

        def set_context(context)
          @context = context
          self
        end

        def to_json(*)
          JSON.pretty_generate(JSON(JSON(data)), quirks_mode: true) # sigh, don't ask…
        end

        private

        def provide_factories
          require_maybe 'factory_girl' do return end
          Dir.chdir(Rails.root.to_s) do
            FactoryGirl.find_definitions
          end
        rescue FactoryGirl::DuplicateDefinitionError
          # OK, handling it this way might be a bit ugly
        end

        def method_missing(*a, &b)
          @context.ask_and_send(*a, &b) or super
        end
      end

      def response(name = :default, &block)
        if block
          responses[name] = Response.new(name, &block).set_context(self)
        else
          responses[name]
        end
      end

      dsl_accessor :description, 'TODO'

      def configure_for_action(action_name)
        action action_name
        action_method controller.instance_method(action_name)
      end

      def url
        Betterplace::Application.routes.url_for(
          {
            controller: controller.name.underscore.sub(/_controller\z/, ''),
            action:     action,
            format:     'api_json', # TODO document somewhere which formats are possible
          } | params | Betterdocs::Global.config.api_url_options
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
