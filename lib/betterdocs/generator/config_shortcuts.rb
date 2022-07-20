module Betterdocs
  module Generator
    module ConfigShortcuts
      def config
        Betterdocs::Global.config
      end

      def project_name
        config.project_name
      end

      def sections
        config.api_controllers.each(&method(:load))
        config.sections
      end

      def section(name)
        name = name.to_sym
        config.section(name) or STDERR.puts "Section #{name.inspect} does not exist: Link in readme file won't work."
        "sections/#{name}"
      end

      def api_base_url
        config
      end
    end
  end
end
