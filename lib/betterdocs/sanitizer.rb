class Betterdocs::Sanitizer
  JSON_NONSTRING_TYPES = Tins::ModuleGroup[
    TrueClass,
    FalseClass,
    NilClass,
    Numeric,
    Array,
    Hash,
  ]

  def initialize(&sanitize)
    @sanitize = sanitize
  end

  def sanitize(value)
    @sanitize or return value
    if JSON_NONSTRING_TYPES === value
      value
    else
      @sanitize.(value.to_s)
    end
  end
end
