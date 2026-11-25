require 'complex_config/rude'

module Betterdocs
  # Global configuration and state for Betterdocs. Provides project-wide
  # settings (names, hosts, directories, assets), URL helpers, and the
  # section/action registry that the generators consume.
  module Global
    class << self
      extend Tins::DSLAccessor
      extend ComplexConfig::Provider::Shortcuts

      # @!method project_name
      #
      # @overload project_name
      #   Returns the name of the project.
      #
      #   @note Defaults to `"Project"`.
      #   @return [String] the project name
      #
      # @overload project_name(name)
      #   Sets the project name.
      #
      #   @param name [String] the project name
      #   @return [String] the project name
      dsl_accessor :project_name,        'Project'

      # @!method api_prefix
      #
      # @overload api_prefix
      #   Returns the prefix that denotes the API namespace in URLs.
      #
      #   @note Defaults to `"api"`.
      #   @return [String] the API prefix
      #
      # @overload api_prefix(prefix)
      #   Sets the API prefix.
      #
      #   @param prefix [String] the prefix
      #   @return [String] the prefix
      dsl_accessor :api_prefix,          'api'

      # @!method controllers_dir
      #
      # @overload controllers_dir
      #   Returns the directory containing API controllers.
      #
      #   @note No explicit value set, so the default block is re-evaluated
      #     on each read: `Rails.root.join('app/controllers')`.
      #   @return [Pathname] the controllers directory
      #
      # @overload controllers_dir(dir)
      #   Sets the controllers directory.
      #
      #   @param dir [Pathname, String] the directory
      #   @return [Pathname] the directory
      dsl_accessor :controllers_dir do
        Betterdocs.rails.root.join('app/controllers')
      end

      # @!method api_controllers
      #
      # @overload api_controllers
      #   Returns a list of all API controller file paths.
      #
      #   @note No explicit value set, so the default block is re-evaluated
      #     on each read: `Dir[controllers_dir + "#{api_prefix}/**/*_controller.rb"]`.
      #   @return [Array<String>] the controller file paths
      #
      # @overload api_controllers(paths)
      #   Sets the list of API controller file paths.
      #
      #   @param paths [Array<String>] the file paths
      #   @return [Array<String>] the file paths
      dsl_accessor :api_controllers do
        Dir[controllers_dir + "#{api_prefix}/**/*_controller.rb"]
      end

      # Parses a URL string and sets protocol/host for the given prefix,
      # or returns the current URL for that prefix when no arg is given.
      #
      # @note Also sets `platform_host` to the parsed host, since the
      #   `api` and `asset` hosts default to it.
      #
      # @param prefix [Symbol] one of `:platform`, `:api`, `:asset`
      # @param url [String, nil] the URL to parse, or nil to read
      # @return [String, nil] the URL string (read mode)
      def handle_url(prefix, url)
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
      private :handle_url

      # Gets or sets the platform base URL.
      #
      # @param url [String, nil] the URL to set, or nil to read
      # @return [String, nil] the platform URL (read mode)
      def platform_url(url = nil)
        handle_url(:platform, url)
      end

      # @!method platform_protocol
      #
      # @overload platform_protocol
      #   Returns the base protocol. The `api_protocol` and
      #   `asset_protocol` accessors default to this value.
      #
      #   @note Defaults to `"http"`.
      #   @return [String] the protocol
      #
      # @overload platform_protocol(protocol)
      #   Sets the base protocol.
      #
      #   @param protocol [String] the protocol
      #   @return [String] the protocol
      dsl_accessor :platform_protocol,   'http'

      # @!method platform_host
      #
      # @overload platform_host
      #   Returns the platform host including port. The `api_host` and
      #   `asset_host` accessors default to this value.
      #
      #   @note Defaults to `"localhost:3000"`.
      #   @return [String] the host with port
      #
      # @overload platform_host(host)
      #   Sets the platform host.
      #
      #   @param host [String] the host including port
      #   @return [String] the host
      dsl_accessor :platform_host,       'localhost:3000'

      # @!method api_protocol
      #
      # @overload api_protocol
      #   Returns the protocol the API understands.
      #
      #   @note No explicit value set, so the default block is re-evaluated
      #     on each read: `platform_protocol`.
      #   @return [String] the API protocol
      #
      # @overload api_protocol(protocol)
      #   Sets the API protocol.
      #
      #   @param protocol [String] the protocol
      #   @return [String] the protocol
      dsl_accessor :api_protocol do platform_protocol end

      # @!method api_host
      #
      # @overload api_host
      #   Returns the API host including port.
      #
      #   @note No explicit value set, so the default block is re-evaluated
      #     on each read: `platform_host`.
      #   @return [String] the API host
      #
      # @overload api_host(host)
      #   Sets the API host.
      #
      #   @param host [String] the host including port
      #   @return [String] the host
      dsl_accessor :api_host do platform_host end

      # Gets or sets the API base URL.
      #
      # @param url [String, nil] the URL to set, or nil to read
      # @return [String, nil] the API URL (read mode)
      def api_url(url = nil)
        handle_url(:api, url)
      end

      # @!method asset_protocol
      #
      # @overload asset_protocol
      #   Returns the asset protocol.
      #
      #   @note No explicit value set, so the default block is re-evaluated
      #     on each read: `platform_protocol`.
      #   @return [String] the asset protocol
      #
      # @overload asset_protocol(protocol)
      #   Sets the asset protocol.
      #
      #   @param protocol [String] the protocol
      #   @return [String] the protocol
      dsl_accessor :asset_protocol do platform_protocol end

      # @!method asset_host
      #
      # @overload asset_host
      #   Returns the Rails asset host.
      #
      #   @note No explicit value set, so the default block is re-evaluated
      #     on each read: `platform_host`.
      #   @return [String] the asset host
      #
      # @overload asset_host(host)
      #   Sets the asset host.
      #
      #   @param host [String] the host
      #   @return [String] the host
      dsl_accessor :asset_host do platform_host end

      # Gets or sets the asset base URL.
      #
      # @param url [String, nil] the URL to set, or nil to read
      # @return [String, nil] the asset URL (read mode)
      def asset_url(url = nil)
        handle_url(:asset, url)
      end

      # @!method api_default_format
      #
      # @overload api_default_format
      #   Returns the default response format for API URLs.
      #
      #   @note Defaults to `"json"`.
      #   @return [String] the format
      #
      # @overload api_default_format(format)
      #   Sets the default API format.
      #
      #   @param format [String] the format
      #   @return [String] the format
      dsl_accessor :api_default_format, 'json'

      # Returns the fully-qualified API base URL (protocol + host + prefix).
      #
      # @return [String] e.g. `https://api.example.com:3000/api`
      def api_base_url
        "#{api_protocol}://#{api_host}/#{api_prefix}"
      end

      # Returns the default URL options hash for generating API URLs.
      #
      # @return [Hash] `{ protocol:, host:, format: }`
      def api_url_options
        { protocol: api_protocol, host: api_host, format: api_default_format }
      end

      # @!method templates_directory
      #
      # @overload templates_directory
      #   Returns the directory containing customised templates, if any
      #   exist.
      #
      #   @note Defaults to `nil`.
      #   @return [String, nil] the templates directory
      #
      # @overload templates_directory(dir)
      #   Sets the templates directory.
      #
      #   @param dir [String] the directory
      #   @return [String] the directory
      dsl_accessor :templates_directory

      # @!method output_directory
      #
      # @overload output_directory
      #   Returns the output directory where the Markdown API docs are
      #   created.
      #
      #   @note Defaults to `"api_docs"`.
      #   @return [String] the output directory
      #
      # @overload output_directory(dir)
      #   Sets the Markdown docs output directory.
      #
      #   @param dir [String] the directory
      #   @return [String] the directory
      dsl_accessor :output_directory, 'api_docs'

      # @!method swagger_output_directory
      #
      # @overload swagger_output_directory
      #   Returns the output directory where the Swagger/OpenAPI docs are
      #   created.
      #
      #   @note Defaults to `"swagger_docs"`.
      #   @return [String] the output directory
      #
      # @overload swagger_output_directory(dir)
      #   Sets the Swagger docs output directory.
      #
      #   @param dir [String] the directory
      #   @return [String] the directory
      dsl_accessor :swagger_output_directory, 'swagger_docs'

      # @!method publish_git
      #
      # @overload publish_git
      #   Returns the URL of the git repository to which the generated
      #   docs are pushed.
      #
      #   @note Defaults to `nil`.
      #   @return [String, nil] the git URL
      #
      # @overload publish_git(url)
      #   Sets the git repository URL for publishing docs.
      #
      #   @param url [String] the git URL
      #   @return [String] the URL
      dsl_accessor :publish_git

      # @!method ignore
      #
      # @overload ignore
      #   Returns all lines of the `.gitignore` file as an array.
      #
      #   @note No explicit value set, so the default block is re-evaluated
      #     on each read: an empty array.
      #   @return [Array<String>] the ignore patterns
      #
      # @overload ignore(patterns)
      #   Sets the ignore patterns.
      #
      #   @param patterns [Array<String>] the patterns
      #   @return [Array<String>] the patterns
      dsl_accessor :ignore do [] end

      # Gets or sets the default sanitize code (evaluated at set time).
      #
      # @param code [String, nil] Ruby code to eval as the sanitizer proc
      # @return [Proc, nil] the compiled sanitizer, or nil if not set
      def default_sanitize(code = nil)
        code and @default_sanitize = eval(code)
        @default_sanitize
      end

      # Replaces the entire assets registry with the entries in +hash+.
      #
      # @param hash [Hash] mapping of source path to destination
      def assets=(hash)
        @assets&.clear
        assets(hash)
      end

      # Returns the assets registry, optionally seeding it from +hash+.
      #
      # @param hash [Hash, nil] mapping of source path to destination
      # @return [Hash] the assets registry
      def assets(hash = nil)
        @assets ||= {}
        hash&.each { |path, to| asset path, to: to }
        @assets
      end

      # Replaces the entire swagger assets registry with entries in +hash+.
      #
      # @param hash [Hash] mapping of source path to destination
      def swagger_assets=(hash)
        @swagger_assets&.clear
        swagger_assets(hash)
      end

      # Returns the swagger assets registry, optionally seeded from +hash+.
      #
      # @param hash [Hash, nil] mapping of source path to destination
      # @return [Hash] the swagger assets registry
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

      # Registers a swagger-specific asset for copying during generation.
      #
      # @param path [String] source path relative to the Rails root
      # @param to [String, Symbol] destination path or `:root`
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

      # Yields each swagger asset's (source, destination) path pair.
      #
      # @yield [path, destination] the source and output paths
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

      # Returns the ComplexConfig-loaded YAML configuration hash,
      # or nil if no configuration file exists.
      #
      # @return [Hash, nil]
      def configuration_file
        cc.betterdocs
      rescue ComplexConfig::ConfigurationFileMissing
      end

      # Applies each key/value pair from the given YAML config to the
      # corresponding `dsl_accessor` on this module.
      #
      # @param config [Hash] the parsed YAML configuration
      def configure_via_yaml(config)
        config.each do |name, value|
          __send__(name, value.dup)
        end
      end

      # Configures Betterdocs from a YAML file and/or a block.
      #
      # @param config [Hash, nil] the config hash (defaults to the loaded file)
      # @yield a block evaluated in this module's context for inline config
      # @return [self]
      def configure(config = configuration_file, &block)
        config and configure_via_yaml(config)
        block  and instance_eval(&block)
        self
      end

      # Returns this module (yielding itself if a block is given).
      #
      # @yield a block receiving this module
      # @return [self]
      def config
        if block_given?
          yield self
        else
          self
        end
      end

      # Scans all API controller files, loads their docs collectors,
      # and returns them as a flat array.
      #
      # @return [Array<Betterdocs::ControllerCollector>] all controller docs
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

      # Returns all documented actions across all controllers, flattened
      # into a single array.
      #
      # @return [Array<Betterdocs::Dsl::Controller::Action>]
      def actions
        all_docs.reduce([]) { |a, d| a.concat(d.actions) }
      end

      # Builds and caches the sections hash, grouping all actions by
      # their `section` into {Section} objects.
      #
      # @return [Hash<Symbol, Betterdocs::Section>] the frozen sections map
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

      # Clears the cached sections hash, forcing a rebuild on next access.
      #
      # @return [self]
      def sections_clear
        @sections = nil
        self
      end

      # Returns the named section if it exists.
      #
      # @param name [Symbol] the section name
      # @return [Betterdocs::Section, nil]
      def section(name)
        sections[name] if sections.key?(name)
      end

      # Returns the Rails URL helpers module for the application.
      #
      # @return [Module]
      def url_helpers
        Betterdocs.rails.application.routes.url_helpers
      end

      # Generates a URL via Rails, merging in the default API URL options.
      #
      # @param options [Hash] routing options
      # @return [String] the generated URL
      def url_for(options = {})
        Betterdocs.rails.application.routes.url_for(
          options | Betterdocs::Global.config.api_url_options
        )
      end
    end
  end
end
