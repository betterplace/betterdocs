require 'betterdocs/dsl/result/property'

class Betterdocs::Dsl::Result::CollectionProperty < Betterdocs::Dsl::Result::Property
  def compute_value(object)
    object.__send__(name).to_a.compact.map do |v|
      represent_with.hashify(v)
    end
  end
end
