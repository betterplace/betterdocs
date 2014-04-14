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
    include Betterdocs::Dsl::Common

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

    def property(name, **options, &block)
      d = doc(:property, name, **options, &block) and
        properties << d
      self
    end

    def collection(name, **options, &block)
      d = doc(:collection_property, name, **options, &block) and
        properties << d
      self
    end

    def links
      @links ||= Set.new
    end

    def link(name, &block)
      d = doc(:link, name, &block) and links << d
      self
    end

    def doc(type, name, **options, &block)
      options |= {
        if:     -> { yes },
        unless: -> { no },
      }
      if options[:if].() && !options[:unless].()
        docs.add_element(self, type, name, options, &block)
      end
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
