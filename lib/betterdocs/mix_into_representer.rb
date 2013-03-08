module Betterdocs
  module MixIntoRepresenter
    def doc(type, &block)
      warn "doc #{type.inspect} wasn't implemented yet"
    end
  end
end
