require 'set'

module Betterdocs::Representer
  extend ActiveSupport::Concern

  module UnfuckRails
    begin
      old, $VERBOSE = $VERBOSE, nil
      generator_methods = JSON.generator::GeneratorMethods
      for const in generator_methods.constants
        refine Object.const_get(const) do
          define_method(:to_json) do |*a|
            generator_methods.const_get(const).instance_method(:to_json).bind(self).(*a)
          end
        end
      end
    ensure
      $VERBOSE = old
    end
  end

  def as_json(*)
    singleton_class.ancestors.find do |c|
      c != singleton_class && c < Betterdocs::Representer
    end.hashify(self)
  end
  alias to_hash as_json

  def to_json(*a)
    JSON::generate(as_json, *a)
  end

  module ClassMethods
    def apply(object)
      object.extend self
    end

    def hashify(object)
      apply(object)
      result = {}
      assign_properties result, object
      assign_links      result, object
      result
    end

    def assign_links(result, object)
      result['links'] = []
      for link in links
        link.assign(result, object)
      end
    end
    private :assign_links

    def assign_properties(result, object)
      for property in properties
        property.assign(result, object)
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

      def actual_property_name
        (options[:as] || name).to_s
      end

      def represent_with
        options[:represent_with]
      end

      def value(object)
        value = object.__send__(name)
        if !value.nil? && represent_with
          represent_with.hashify(value)
        else
          value
        end
      end

      def assign(result, object)
        result[actual_property_name] = value(object)
      end
    end

    def property(name, options = {}, &block) # TODO
      doc :api_property, name, options, &block
      properties << Property.new(name, options)
      self
    end

    class CollectionProperty < Property
      def initialize(name, options)
        super
        @options[:represent_with] or
          raise ArgumentError, 'option :represent_with is required'
      end

      def value(object)
        object.__send__(name).to_a.compact.map do |v|
          represent_with.hashify(v)
        end
      end
    end

    def collection(name, options)
      properties << CollectionProperty.new(name, options)
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

      def assign(result, object)
        result['links'].push(
          'rel'  => name.to_s,
          'href' => object.instance_eval(&url).to_s,
        )
      end
    end

    def link(name, options ={}, &block) # TODO
      doc :api_link, name, options, &block
      links << Link.new(name, &docs.api_link(name).url)
      self
    end

    def doc(type, name, options = {}, &block)
      docs.add_element(self, type, name, options, &block)
    end

    def object_name(*) end

    def api_url_for(options = {})
      Betterdocs::Global.url_for(options)
    end

    def docs
      @docs ||= Betterdocs::RepresenterCollector.new
    end
  end
end

module Betterdocs
  def self.const_missing(id)
    if id == :MixIntoRepresenter
      warn "constant Betterdocs::MixIntoRepresenter is deprecated!"
      const_set(:MixIntoRepresenter, Representer)
    else
      super
    end
  end
end

using Betterdocs::Representer::UnfuckRails
