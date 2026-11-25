require 'set'
require 'betterdocs/representer'

# A representer module for API response objects that carry both typed
# properties and hypermedia links.
#
# Include this module in a concern or module that decorates response
# objects. It provides the DSL for declaring `property`, `collection`,
# and `link` elements, and serializes the decorated object via
# {#as_json} / {#to_hash} / {#to_json}.
#
# @example Declaring a result representer
#   module ClientRepresenter
#     extend ActiveSupport::Concern
#     include Betterdocs::ResultRepresenter
#
#     property :name, as: :client_name do
#       description 'The client display name'
#       types String
#     end
#
#     link :self do
#       description 'Self link'
#       url { client_url(id) }
#     end
#   end
module Betterdocs::ResultRepresenter
  extend ActiveSupport::Concern
  include Betterdocs::Dsl::Common
  include Betterdocs::Representer
  include Betterdocs::Responding

  # Methods `extend`ed onto the including class via
  # `ActiveSupport::Concern`: serializes properties and links,
  # registers docs, and exposes `property`, `collection`, `link`.
  module ClassMethods
    # Serializes the object by delegating to {Betterdocs::Representer}
    # and then assigning all declared properties and links into the
    # result hash.
    #
    # @param object [Object] the object to serialize
    # @return [Hash] the serialized result with properties and links
    def hashify(object)
      super do |result|
        assign_properties result, object
        assign_links      result, object
      end
    end

    # Registers a documentation element with the {#docs} collector.
    #
    # @param type [Symbol] the element type (e.g. `:property`, `:link`)
    # @param name [Symbol] the name of the element
    # @param options [Hash] additional options forwarded to the element
    # @return [Betterdocs::Dsl::Representer] the registered element
    def doc(type, name, **options, &block)
      docs.add_element(self, type, name, **options, &block)
    end

    # Returns the documentation collector for this representer, lazily
    # initialized on first access.
    #
    # @return [Betterdocs::ResultRepresenterCollector]
    def docs
      @docs ||= Betterdocs::ResultRepresenterCollector.new
    end

    # Assigns all declared links into the result hash under the
    # `links` key.
    #
    # @param result [Hash] the container to populate
    # @param object [Object] the source object to read link data from
    def assign_links(result, object)
      result['links'] = []
      for link in links
        link.assign(result, object)
      end
    end
    private :assign_links

    # Assigns all declared properties into the result hash by
    # delegating to each property's `#assign` method.
    #
    # @param result [Hash] the container to populate
    # @param object [Object] the source object to read property data from
    def assign_properties(result, object)
      for property in properties
        property.assign(result, object)
      end
    end
    private :assign_properties

    # Returns the set of all declared property and collection elements.
    #
    # @return [Set] of {Betterdocs::Dsl::Result::Property} elements
    def properties
      @properties ||= Set.new
    end

    # Declares a single-value property on the response object.
    #
    # @param name [Symbol] the source attribute name
    # @option :as [Symbol] the output key name (defaults to +name+)
    # @option :if [Proc] block evaluated on the response object; the
    #   property is included only when the block returns truthy
    # @option :unless [Proc] block evaluated on the response object; the
    #   property is excluded when the block returns truthy
    # @yield The DSL block for configuring description, types, etc.
    # @return [self]
    def property(name, **options, &block)
      d = doc(:property, name, **options, &block) and
        properties << d
      self
    end

    # Declares a collection (array) property on the response object.
    #
    # @param name [Symbol] the source attribute name
    # @option :as [Symbol] the output key name (defaults to +name+)
    # @option :if [Proc] block evaluated on the response object; the
    #   collection is included only when the block returns truthy
    # @option :unless [Proc] block evaluated on the response object; the
    #   collection is excluded when the block returns truthy
    # @yield The DSL block for configuring description, types, etc.
    # @return [self]
    def collection(name, **options, &block)
      d = doc(:collection_property, name, **options, &block) and
        properties << d
      self
    end

    # Returns the set of all declared link elements.
    #
    # @return [Set] of {Betterdocs::Dsl::Result::Link} elements
    def links
      @links ||= Set.new
    end

    # Declares a hypermedia link on the response object.
    #
    # @param name [Symbol] the link name
    # @option :if [Proc] block evaluated on the response object; the
    #   link is included only when the block returns truthy
    # @option :unless [Proc] block evaluated on the response object; the
    #   link is excluded when the block returns truthy
    # @yield The DSL block for configuring description and url
    # @return [self]
    def link(name, **options, &block)
      d = doc(:link, name, **options, &block) and links << d
      self
    end
  end
end
