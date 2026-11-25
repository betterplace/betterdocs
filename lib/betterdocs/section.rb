require 'tins/named_set'

module Betterdocs
  # A named container grouping documented actions that share the same
  # `section` name. Subclasses `Tins::NamedSet` to provide name-based
  # identity and set semantics.
  class Section < Tins::NamedSet
  end
end
