module Betterdocs::Representer
  extend ActiveSupport::Concern

  module ClassMethods
    def property(name, options = {}) # TODO
    end

    def link(name, &url) # TODO
    end

    def doc(type, name, options = {}, &block)
      docs.add_element(self, type, name, options, &block)
    end

    def object_name(*) end

    def api_property(name, options = {}, &block)
      doc :api_property, name, options, &block
      docs.api_property(name).define
    end

    def api_link(name, options = {}, &block)
      doc :api_link, name, options, &block
      docs.api_link(name).define
    end

    def api_url_for(options = {})
      Betterdocs::Global.url_for(options)
    end

    def docs
      @docs ||= Betterdocs::RepresenterCollector.new
    end
  end
end
