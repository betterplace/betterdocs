module Betterdocs
  module Generator
    # Shortcut methods that delegate to {Betterdocs::Global.config}
    # for use inside ERB generator templates.
    module ConfigShortcuts
      # Returns the global configuration singleton.
      #
      # @return [Betterdocs::Global] the global config
      def config
        Betterdocs::Global.config
      end

      # Returns the configured project name.
      #
      # @return [String] the project name
      def project_name
        config.project_name
      end

      # Loads all API controllers and returns the collected sections.
      #
      # @return [Hash{Symbol => Betterdocs::Section}] the sections
      def sections
        config.api_controllers.each(&method(:load))
        config.sections
      end

      # Returns the relative path for a section, warning if the
      # section does not exist.
      #
      # @param name [Symbol, String] the section name
      # @return [String] the relative path to the section
      def section(name)
        name = name.to_sym
        config.section(name) or STDERR.puts "Section #{name.inspect} does not exist: Link in readme file won't work."
        "sections/#{name}"
      end

      # Returns the global configuration (aliased for template use).
      #
      # @return [Betterdocs::Global] the global config
      def api_base_url
        config
      end
    end
  end
end
