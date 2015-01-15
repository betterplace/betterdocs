module Betterdocs
  module Dsl
    class ControllerBase
      include Common

      def self.inherited(klass)
        klass.class_eval { extend DSLKit::DSLAccessor }
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

    class Controller < ControllerBase
      def name
        @name ||= controller.to_s.underscore.sub(/_controller\z/, '').to_sym
      end

      dsl_accessor :section

      dsl_accessor :description, 'TODO'

      def url
        Betterdocs::Global.url_for(
          controller: name, action: :index, format: 'json')
      end

      def url_helpers
        Betterdocs::Global.url_helpers
      end

      def to_s
        [ controller, '', "url: #{url}", '', description, '' ] * "\n"
      end

      def add_to_collector(collector)
        collector.controller = self
      end
    end

    class Action < ControllerBase
      dsl_accessor :action

      alias name action

      dsl_accessor :title do "All about: #{action}" end

      dsl_accessor :section do
        controller.docs.controller.full?(:section) || :misc
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
        else
          raise ArgumentError, "Cannot automatically derive http_method for #{name.inspect}, specify manually"
        end
      end

      dsl_accessor :params do {} end

      dsl_accessor :private, false

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

        def params
          -> name { param(name).full?(:value) }
        end

        def data
          @data ||= instance_eval(&@data_block)
        end

        def properties
          representer.full? { |r| r.docs.nested_properties }  || []
        end

        def links
          representer.full? { |r| r.docs.nested_links }  || []
        end

        def representer
          if data
            data.ask_and_send(:representer) ||
              data.singleton_class.ancestors.find { |c|
                Betterdocs::Representer >= c && c.respond_to?(:docs)
                # Actually it's more like
                #   Betterdocs::Representer >= c && !c.singleton_class?
                # in newer rubies.
                # But singleton_class? is broken and private in ruby 2.1.x not
                # existant in <= ruby 2.0.x and finally works in ruby 2.2.x.
                # What a mess!
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
        "#{http_method.to_s.upcase} #{url}"
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

      def add_to_collector(collector)
        collector.element = self
      end
    end
  end
end
