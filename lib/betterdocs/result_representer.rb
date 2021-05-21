require 'set'
require 'betterdocs/representer'

module Betterdocs::ResultRepresenter
  extend ActiveSupport::Concern
  include Betterdocs::Dsl::Common
  include Betterdocs::Representer

  module ClassMethods
    def hashify(object)
      super do |result|
        assign_properties result, object
        assign_links      result, object
      end
    end

    def doc(type, name, **options, &block)
      docs.add_element(self, type, name, **options, &block)
    end

    def docs
      @docs ||= Betterdocs::ResultRepresenterCollector.new
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
  end
end
