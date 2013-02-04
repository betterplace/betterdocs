module Betterdocs
  module Global
    class << self
      def sections
        unless @sections
          Dir.chdir Rails.root.join('app/controllers') do
            all_docs = []
            for cf in Dir['api_v4/**/*_controller.rb']
              controller_name = cf.sub(/\.rb$/, '').camelcase
              begin
                controller = controller_name.constantize
                if docs = controller.ask_and_send(:docs)
                  all_docs << docs
                else
                  warn "Skipping #{cf.inspect}, #{controller_name.inspect} doesn't respond to :docs method"
                end
              rescue NameError => e
                warn "Skipping #{cf.inspect}, #{e.class}: #{e}"
              end
            end
            actions = all_docs.reduce([]) { |a, d| a.concat(d.actions) }
            actions.each_with_object(@sections = {}) do |action, sections|
              sections[action.section] ||=
                Section.new(action.section)
              sections[action.section] << action
            end
          end
          @sections.freeze
        end
        @sections
      end

      def section(name)
        sections[name] if sections.key?(name)
      end

      attr_accessor :templates_directory
    end
  end
end
