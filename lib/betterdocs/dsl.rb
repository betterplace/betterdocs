require 'dslkit/polite'
require 'tins/xt/to'

module Betterdocs
  module Dsl
    module Common
      extend DSLKit::Constant

      constant :yes, true

      constant :no,  false

      def set_context(context)
        @__context__ = context
        self
      end

      private

      def method_missing(name, *a, &b)
        if @__context__
          @__context__.__send__(name, *a, &b)
        else
          super
        end
      end
    end

    class Controller
      extend DSLKit::DSLAccessor
      include Common

      def initialize(controller, &block)
        @controller = controller
        set_context @controller
        instance_eval(&block)
      end

      dsl_accessor :controller

      def name
        @name ||= controller.to_s.underscore.sub(/_controller\z/, '').to_sym
      end

      dsl_accessor :section

      dsl_accessor :description, 'TODO'

      def url
        Betterdocs.rails.application.routes.url_for(
          {
            controller: name,
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

      dsl_accessor :title do "All about: #{action}" end

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
        name = name.to_sym
        if block
          param = Param.new(name, &block)
          param.value or param.value params.size + 1
          params[name] = param
        else
          params[name]
        end
      end

      dsl_accessor :responses do {} end

      class Response
        include Common
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

        def properties
          representer.full? { |r| r.docs.nested_api_properties }  || []
        end

        def links
          representer.full? { |r| r.docs.nested_api_links }  || []
        end

        def representer
          if data
            data.ask_and_send(:representer) ||
              data.singleton_class.ancestors.find { |c|
                Betterdocs::MixIntoRepresenter >= c
              }
          end
        end

        def to_json(*)
          JSON.pretty_generate(JSON.load(JSON.dump(data)), quirks_mode: true) # sigh, don't ask…
        rescue TypeError => e
          STDERR.puts "Caught #{e}: #{e.message} for #{data.inspect}"
          nil
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

    class ApiProperty
      extend DSLKit::DSLAccessor
      include Common

      dsl_accessor :representer

      dsl_accessor :represent_with

      dsl_accessor :description, 'TODO'

      dsl_accessor :example, 'TODO'

      dsl_accessor :types do [] end


      attr_reader :name

      attr_reader :options

      def initialize(representer, name, options, &block)
        @representer = representer
        set_context @representer
        @path = []
        @name = name.to_sym
        @options = options
        block and instance_eval(&block)
        types JsonTypeMapper.map_types(types)
        if sr = sub_representer?
          sr < Betterdocs::MixIntoRepresenter or
            raise TypeError, "#{sr.inspect} is not a Betterdocs::MixIntoRepresenter subclass"
          @options[:extend] = sr
        end
      end

      def below_path(path)
        @path = path
        self
      end

      def public_name
        @options[:as] || name
      end

      def full_name
        (@path + [ public_name ]) * '.'
      end

      def sub_representer?
        represent_with
      end

      def define
        representer.__send__ :property, name, options
        self
      end
    end

    class ApiLink
      extend DSLKit::DSLAccessor
      include Common

      attr_reader :name

      dsl_accessor :representer

      dsl_accessor :description, 'TODO'

      attr_reader :name

      def initialize(representer, name, &block)
        @representer = representer
        set_context @representer
        @path = []
        @name = name.to_sym
        block and instance_eval(&block)
      end

      def below_path(path)
        @path = path
        self
      end

      def full_name
        (@path + [ name ]) * '.'
      end

      def url(&block)
        if block
          @url = block
        elsif @url
          @url
        else
          raise ArgumentError, 'link requires an URL'
        end
      end

      def define
        url or raise ArgumentError, "url has to be defined for #{representer}##{name}"
        representer.__send__ :link, name, &url
        self
      end
    end
  end
end
