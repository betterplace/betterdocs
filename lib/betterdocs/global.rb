require 'complex_config/rude'

module Betterdocs
  module Global
    class << self
      extend Tins::DSLAccessor
      extend ComplexConfig::Provider::Shortcuts

      dsl_accessor :project_name,        'Project'         # Name of the project

      dsl_accessor :api_prefix,          'api'             # Prefix that denotes the api namespace in URLs

      dsl_accessor :controllers_dir do
        Betterdocs.rails.root.join('app/controllers')
      end

      dsl_accessor :api_controllers do
        Dir[controllers_dir + "#{api_prefix}/**/*_controller.rb"]
      end

      private def handle_url(prefix, url)
        if url
          uri = URI.parse(url)
          __send__("#{prefix}_protocol", uri.scheme || 'http')
          host = uri.host || 'localhost'
          port = uri.port and host = "#{host}:#{port}"
          platform_host host
          __send__("#{prefix}_host", host)
        else
          [__send__("#{prefix}_protocol"), __send__("#{prefix}_host")].join('://')
        end
      end

      def platform_url(url = nil)
        handle_url(:platform, url)
      end

      dsl_accessor :platform_protocol,   'http'               # Not used atm

      dsl_accessor :platform_host,       'localhost:3000'     # Actually host with port, but rails seems to be confused about the concept

      dsl_accessor :api_protocol do platform_protocol end     # Protocol the API understands

      dsl_accessor :api_host do platform_host end # Hostname of the API (eventuallly with port number)

      def api_url(url = nil)
        handle_url(:api, url)
      end

      dsl_accessor :asset_protocol do platform_protocol end   # Reserved

      dsl_accessor :asset_host do platform_host end           # Rails asset host

      def asset_url(url = nil)
        handle_url(:asset, url)
      end

      dsl_accessor :api_default_format, 'json'

      def api_base_url
        "#{api_protocol}://#{api_host}/#{api_prefix}"
      end

      def api_url_options
        { protocol: api_protocol, host: api_host, format: api_default_format }
      end

      dsl_accessor :templates_directory # Template directory, where customised templates live if any exist

      dsl_accessor :output_directory, 'api_docs' # Output directory, where the api docs are created

      dsl_accessor :swagger_output_directory, 'swagger_docs' # Output directory, where the swagger docs are created

      dsl_accessor :publish_git                             # URL to the git repo to which the docs are pushed

      dsl_accessor :ignore do [] end                        # All lines of the .gitignore file as an array

      def default_sanitize(code = nil)
        code and @default_sanitize = eval(code)
        @default_sanitize
      end

      def assets=(hash)
        @assets&.clear
        assets(hash)
      end

      def assets(hash = nil)
        @assets ||= {}
        hash&.each { |path, to| asset path, to: to }
        @assets
      end

      def swagger_assets=(hash)
        @swagger_assets&.clear
        swagger_assets(hash)
      end

      def swagger_assets(hash = nil)
        @swagger_assets ||= {}
        hash&.each { |path, to| swagger_asset path, to: to }
        @swagger_assets
      end

      # Defines an asset for the file at +path+. If +to+ was given it will be
      # copied to this path (it includes the basename) below
      # +templates_directory+ in the output, otherwise it will be copied
      # directly to +templates_directory+.
      def asset(path, to: :root)
        @assets ||= {}
        if destination = to.ask_and_send(:to_str)
          @assets[path.to_s] = destination
        elsif to == :root
          @assets[path.to_s] = to
        else
          raise ArgumentError, 'keyword argument to needs to be a string or :root'
        end
      end

      def swagger_asset(path, to: :root)
        @swagger_assets ||= {}
        if destination = to.ask_and_send(:to_str)
          @swagger_assets[path.to_s] = destination
        elsif to == :root
          @swagger_assets[path.to_s] = to
        else
          raise ArgumentError, 'keyword argument to needs to be a string or :root'
        end
      end

      # Maps the assets original source path to its destination path in the
      # output by yielding to every asset's source/destination pair.
      def each_asset
        assets.each do |(path, destination)|
          path = path.to_s
          if destination == :root
            yield path, File.join(output_directory.to_s, File.basename(path))
          else
            yield path, File.join(output_directory.to_s, destination.to_str)
          end
        end
      end

      def each_swagger_asset
        swagger_assets.each do |(path, destination)|
          path = path.to_s
          if destination == :root
            yield path, File.join(swagger_output_directory.to_s, File.basename(path))
          else
            yield path, File.join(swagger_output_directory.to_s, destination.to_str)
          end
        end
      end

      def configuration_file
        cc.betterdocs
      rescue ComplexConfig::ConfigurationFileMissing
      end

      def configure_via_yaml(config)
        config.each do |name, value|
          __send__(name, value.dup)
        end
      end

      def configure(config = configuration_file, &block)
        config and configure_via_yaml(config)
        block  and instance_eval(&block)
        self
      end

      def config
        if block_given?
          yield self
        else
          self
        end
      end

      def all_docs
        Dir.chdir controllers_dir do
          Dir["#{api_prefix}/**/*_controller.rb"].each_with_object([]) do |cf, all|
            controller_name = cf.sub(/\.rb$/, '').camelcase
            controller =
              begin
                controller_name.constantize
              rescue NameError => e
                STDERR.puts "Skipping #{cf.inspect}, #{e.class}: #{e}"
                next
              end
            if docs = controller.ask_and_send(:docs)
              all << docs
            else
              STDERR.puts "Skipping #{cf.inspect}, #{controller_name.inspect} doesn't respond to :docs method"
            end
          end
        end
      end

      def actions
        all_docs.reduce([]) { |a, d| a.concat(d.actions) }
      end

      def sections
        @sections and return @sections
        Dir.chdir controllers_dir do
          actions.each_with_object(@sections = {}) do |action, sections|
            sections[action.section] ||= Section.new(action.section)
            sections[action.section] << action
          end
        end
        @sections.freeze
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
          options | Betterdocs::Global.config.api_url_options
        )
      end
    end
  end
end
