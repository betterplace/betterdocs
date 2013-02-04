module Betterdocs
  module Generator
    class Markdown
      require 'fileutils'
      include FileUtils::Verbose

      def generate_to(dirname)
        prepare_dir dirname
        create_sections(dirname)
        create_readme dirname
        self
      end

      def create_sections(dirname)
        cd dirname do
          for section in sections.values
            warn "Creating section #{section.name.inspect}."
            render_to "sections/#{section.name}.md", section_template, section.instance_eval('binding')
          end
        end
        self
      end

      def create_readme(dirname)
        name = 'README.md'
        cd dirname do
          warn "Creating readme."
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
      end

      def sections
        Betterdocs::Global.sections
      end

      def section(name)
        name = name.to_sym
        Betterdocs::Global.section(name) or warn "Section #{name.inspect} does not exist: Link in readme file won't work."
        "sections/#{name}"
      end

      def default_templates_directory
        File.join File.dirname(__FILE__), 'markdown', 'templates'
      end

      def read_template(filename)
        warn "Now reading #{filename.inspect}."
        File.read(filename)
      end

      def provide_template(template_subpath)
        if templates_directory = Betterdocs::Global.full?(:templates_directory)
          path = File.expand_path(template_subpath, templates_directory)
          File.file?(path) and return read_template(path)
        end
        path = File.expand_path(template_subpath, default_templates_directory)
        File.file?(path) and return read_template(path)
          message = "#{template_subpath.inspect} missing"
        warn " *** #{message}"
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
            rm_rf Dir[dirname + '/**/*']
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
