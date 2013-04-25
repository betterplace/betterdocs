module Betterdocs
  module Generator
    class Markdown
      include ::Betterdocs::Generator::ConfigShortcuts
      require 'fileutils'
      include FileUtils::Verbose
      require 'term/ansicolor'
      include Term::ANSIColor

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
            STDERR.puts "Creating section #{section.name.inspect}."
            render_to "sections/#{section.name}.md", section_template, section.instance_eval('binding')
          end
        end
        self
      end

      def create_readme(dirname)
        name = 'README.md'
        cd dirname do
          STDERR.puts "Creating readme."
          render_to name, readme_template, binding
        end
        self
      end

      private

      def render_to(filename, template, binding)
        File.open(filename, 'w') do |output|
          output.write ERB.new(template, nil, '-').result(binding)
        end
        self
      rescue => e
        message = blink(color(231, on_color(124,
          " *** ERROR #{e.class}: #{e} in template ***\n")))
        STDERR.puts \
          message, color(88, on_color(136, template)), message,
          color(136, (%w[Backtrace:] + e.backtrace) * "\n"),
          message
        exit 1
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
