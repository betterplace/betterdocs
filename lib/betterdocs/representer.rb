require 'set'

module Betterdocs::Representer
  extend ActiveSupport::Concern
  include Betterdocs::Dsl::Common

  def as_json(*)
    singleton_class.ancestors.find do |c|
      c != singleton_class && c < Betterdocs::Representer
    end.hashify(self)
  end

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

    def link(name, **options, &block)
      d = doc(:link, name, **options, &block) and links << d
      self
    end

    def doc(type, name, **options, &block)
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
