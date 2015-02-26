module Betterdocs
  module Generator
    class Markdown
      include ::Betterdocs::Generator::ConfigShortcuts
      require 'fileutils'
      include FileUtils::Verbose
      require 'term/ansicolor'
      include Term::ANSIColor

      def initialize(only: nil)
        only and @only = Regexp.new(only)
      end

      def generate
        if dir = config.output_directory.full?
          generate_to dir
        else
          fail "Specify an output_directory in your configuration!"
        end
      end

      def generate_to(dirname)
        configure_for_creation
        prepare_dir dirname
        create_sections(dirname)
        create_readme dirname
        create_assets
        self
      end

      def configure_for_creation
        STDERR.puts "Setting asset_host to #{Betterdocs::Global.asset_host.inspect}."
        Betterdocs.rails.configuration.action_controller.asset_host = Betterdocs::Global.asset_host
        options = {
          host:     Betterdocs::Global.api_host,
          protocol: Betterdocs::Global.api_protocol
        }
        STDERR.puts "Setting default_url_options to #{options.inspect}."
        Betterdocs.rails.application.routes.default_url_options = options
        self
      end

      def create_sections(dirname)
        cd dirname do
          for section in sections.values
            if @only
              @only =~ section.name or next
            end
            STDERR.puts on_color(33, "Creating section #{section.name.inspect}.")
            render_to "sections/#{section.name}.md", section_template, section.instance_eval('binding')
          end
        end
        self
      end

      def create_readme(dirname)
        name = 'README.md'
        cd dirname do
          STDERR.puts on_color(33, "Creating readme.")
          render_to name, readme_template, binding
        end
        self
      end

      def create_assets
        config.each_asset do |src, dst|
          STDERR.puts on_color(33, "Creating asset #{dst.inspect} from #{src.inspect}.")
          mkdir_p File.dirname(dst)
          cp src, dst
        end
      end

      private

      def fail_while_rendering(template, exception)
        message = blink(color(231, on_color(
          124, " *** ERROR #{exception.class}: #{exception.message.inspect} in template ***")))
        STDERR.puts message
        Timeout.timeout(5, Timeout::Error) do
          STDERR.print "Output long error message? (yes/NO) "
          if STDIN.gets =~ /\Ay/i
            STDERR.puts color(88, on_color(136, template)), message,
              color(136, (%w[Backtrace:] + exception.backtrace) * "\n"),
              message
          end
        end
      rescue Timeout::Error
        STDERR.puts "Nope…"
      ensure
        exit 1
      end

      def render_to(filename, template, binding)
        File.open(filename, 'w') do |output|
          rendered = ERB.new(template, nil, '-').result(binding)
          output.write rendered
        end
        self
      rescue => e
        fail_while_rendering(template, e)
      end

      def default_templates_directory
        File.join File.dirname(__FILE__), 'markdown', 'templates'
      end

      def read_template(filename)
        STDERR.puts "Now reading #{filename.inspect}."
        File.read(filename)
      end

      def provide_template(template_subpath)
        if templates_directory = config.full?(:templates_directory)
          path = File.expand_path(template_subpath, templates_directory)
          File.file?(path) and return read_template(path)
        end
        path = File.expand_path(template_subpath, default_templates_directory)
        File.file?(path) and return read_template(path)
          message = "#{template_subpath.inspect} missing"
        STDERR.puts " *** #{message}"
        "[#{message}]"
      end

      def readme_template
        provide_template 'README.md.erb'
      end
      memoize_method :readme_template

      def section_template
        provide_template 'section.md.erb'
      end
      memoize_method :section_template

      def prepare_dir(dirname)
        dirname.present? or raise ArgumentError,
          "#{dirname.inspect} should be an explicite output dirname"
        begin
          stat = File.stat(dirname)
          if stat.directory?
            rm_rf Dir[dirname.to_s + '/**/*']
          else
            raise ArgumentError, "#{dirname.inspect} is not a directory"
          end
        rescue Errno::ENOENT
        end
        mkdir_p "#{dirname}/sections"
        self
      end
    end
  end
end
