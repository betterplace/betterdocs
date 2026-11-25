require 'betterdocs/dsl/result/property'

# A property that represents a collection of objects, each rendered
# through a {Betterdocs::ResultRepresenter}. Inherits from
# {Betterdocs::Dsl::Result::Property} and overrides value computation
# to map over array elements.
class Betterdocs::Dsl::Result::CollectionProperty < Betterdocs::Dsl::Result::Property
  # Maps each non-nil element of the array through the
  # `represent_with` representer.
  #
  # @param object [Object] the source object
  # @return [Array] the serialized collection
  def compute_value(object)
    object.__send__(name).to_a.compact.map do |v|
      represent_with.hashify(v)
    end
  end
end
