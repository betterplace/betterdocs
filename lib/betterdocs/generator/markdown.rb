require 'infobar'
require 'fileutils'
require 'term/ansicolor'

module Betterdocs
  module Generator
    class Markdown
      include ::Betterdocs::Generator::ConfigShortcuts
      include Term::ANSIColor
      include FileUtils

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
        infobar.puts color(40, "Setting asset_host to #{Betterdocs::Global.asset_host.inspect}.")
        Betterdocs.rails.configuration.action_controller.asset_host = Betterdocs::Global.asset_host
        options = {
          host:     Betterdocs::Global.api_host,
          protocol: Betterdocs::Global.api_protocol
        }
        infobar.puts color(40, "Setting default_url_options to #{options.inspect}.")
        Betterdocs.rails.application.routes.default_url_options = options
        self
      end

      def create_sections(dirname)
        Infobar(total: sections.size)
        cd dirname do
          for section in sections.values
            infobar.progress(
              message: " Section #{section.name.to_s.inspect} %c/%t in %te ETA %e @%E ",
              force:   true
            )
            if @only
              @only =~ section.name or next
            end
            render_to "sections/#{section.name}.md", section_template, section.instance_eval('binding')
          end
        end
        infobar.finish message: ' %t sections created in %te, completed @%E '
        infobar.newline
        self
      end

      def create_readme(dirname)
        name = 'README.md'
        cd dirname do
          infobar.puts color(40, "Creating readme.")
          render_to name, readme_template, binding
        end
        self
      end

      def create_assets
        Infobar(total: config.assets.size)
        config.each_asset do |src, dst|
          infobar.progress(
            message: " Asset #{File.basename(src).inspect} %c/%t in %te ETA %e @%E ",
            force:   true
          )
          mkdir_p File.dirname(dst)
          cp Betterdocs.rails.root.join(src), dst
        end
        infobar.finish message: ' %t assets created in %te, completed @%E '
        infobar.newline
        self
      end

      private

      def fail_while_rendering(template, exception)
        message = color(
          231,
          on_color( 124, " *** ERROR #{exception.class}: #{exception.message.inspect} in template ***")
        )
        unless Betterdocs::Dsl::Controller::Action::Response::Error === exception
          infobar.puts color(88, on_color(136, template))
        end
        infobar.puts color(136, (%w[Location:] + exception.backtrace) * "\n"),
          message
        exit 1
      end

      def render_to(filename, template, binding)
        File.open(filename, 'w') do |output|
          rendered = ERB.new(template, trim_mode: '-').result(binding)
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
        infobar.puts color(40, "Now reading #{filename.inspect}.")
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
        infobar.puts " *** #{message}"
        "[#{message}]"
      end

      memoize method:
      def readme_template
        provide_template 'README.md.erb'
      end

      memoize method:
      def section_template
        provide_template 'section.md.erb'
      end

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
