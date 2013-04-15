require 'dslkit/polite'

module Betterdocs
  module Global
    class << self
      extend DSLKit::DSLAccessor

      dsl_accessor :project_name,        'Project'         # Name of the project

      dsl_accessor :api_prefix,          'api'             # Prefix that denotes the api namespace in URLs

      dsl_accessor :api_controllers do
        Dir[Rails.root.join("app/controllers/#{api_prefix}/**/*_controller.rb")]
      end

      dsl_accessor :api_protocol,        'https'           # Protocol the API understands

      dsl_accessor :api_host,            'localhost:3000'  # Actually host with port, but rails seems to be confused about the concept

      dsl_accessor :asset_host do api_host end

      dsl_accessor :api_default_format,  'json'

      def api_base_url
        "#{api_protocol}://#{api_host}/#{api_prefix}"
      end

      dsl_accessor :api_url_options do
        { protocol: api_protocol, host: api_host, format: api_default_format }
      end

      dsl_accessor :templates_directory                     # Template directory, where customised templates live if any exist

      dsl_accessor :output_directory,    'api_docs'         # Output directory, where the api docs are created

      dsl_accessor :publish_git                             # URL to the git repo to which the docs are pushed

      dsl_accessor :ignore do [] end                        # All lines of the .gitignore file as an array

      def configure(&block)
        instance_eval(&block)
        self
      end

      def config
        if block_given?
          yield self
        else
          self
        end
      end

      def sections
        unless @sections
          Dir.chdir Rails.root.join('app/controllers') do
            all_docs = []
            for cf in Dir[api_prefix.to_s + '/**/*_controller.rb']
              controller_name = cf.sub(/\.rb$/, '').camelcase
              controller =
                begin
                  controller_name.constantize
                rescue NameError => e
                  STDERR.puts "Skipping #{cf.inspect}, #{e.class}: #{e}"
                  next
                end
              if docs = controller.ask_and_send(:docs)
                all_docs << docs
              else
                STDERR.puts "Skipping #{cf.inspect}, #{controller_name.inspect} doesn't respond to :docs method"
              end
            end
            actions = all_docs.reduce([]) { |a, d| a.concat(d.actions) }
            actions.each_with_object(@sections = {}) do |action, sections|
              sections[action.section] ||= Section.new(action.section)
              sections[action.section] << action
            end
          end
          @sections.freeze
        end
        @sections
      end

      def sections_clear
        @sections = nil
        self
      end

      def section(name)
        sections[name] if sections.key?(name)
      end

      def url_helpers
        Betterdocs.rails.application.routes.url_helpers
      end

      def url_for(options = {})
        Betterdocs.rails.application.routes.url_for(
          options | Betterdocs::Global.config.api_url_options)
      end
    end
  end
end
