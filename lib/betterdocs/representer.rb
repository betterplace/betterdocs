require 'set'

module Betterdocs::Representer
  extend ActiveSupport::Concern

  module ClassMethods
    def jsonify(object, options = {})
      JSON.generate(hashify(object), options)
    end

    def hashify(object)
      result = {}
      assign_properties result, object
      assign_links result, object
      result
    end

    def assign_links(result, object)
      for link in links
        result[link.name] = object.instance_eval(&link.url)
      end
    end
    private :assign_links

    def assign_properties(result, object)
      for property in properties
        name  = (property.options[:as] || property.name).to_s
        value =
          if method_defined?(property.name)
            instance_method(property.name).bind(object).call
          else
            object.__send__(property.name)
          end
        result[name] =
          if subrepresenter = property.options[:represent_with]
            subrepresenter.hashify(value)
          else
            value
          end
      end
    end
    private :assign_properties

    def properties
      @properties ||= Set.new
    end

    class Property
      def initialize(name, options)
        @name, @options = name, options.symbolize_keys
      end

      attr_reader :name

      attr_reader :options
    end

    def property(name, options = {}) # TODO
      properties << Property.new(name, options)
      self
    end

    def links
      @links ||= Set.new
    end

    class Link
      def initialize(name, &url)
        @name, @url = name, url
      end

      attr_reader :name

      attr_reader :url
    end

    def link(name, &url) # TODO
      links << Link.new(name, &url)
      self
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
