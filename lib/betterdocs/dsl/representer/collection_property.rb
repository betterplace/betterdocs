require 'betterdocs/dsl/representer/property'

class Betterdocs::Dsl::Representer::CollectionProperty < Betterdocs::Dsl::Representer::Property
  def value(object)
    object.__send__(name).to_a.compact.map do |v|
      represent_with.hashify(v)
    end
  end
end
