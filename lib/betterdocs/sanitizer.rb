# Applies an optional sanitization lambda to string values in the
# property serialization path (live API responses and generated
# documentation). Non-string JSON types (booleans, nil, numerics,
# arrays, hashes) are passed through unchanged.
#
# Security note: this is the stored-XSS gate for user-generated content
# (e.g. Trix editor HTML). A property without a `sanitize` proc (and no
# global `default_sanitize`) lets raw user HTML flow into the JSON
# response, which is a stored XSS risk for any consuming frontend that
# renders it into the DOM.
class Betterdocs::Sanitizer
  # Classes that represent non-string JSON values and should skip
  # sanitization.
  JSON_NONSTRING_TYPES = Tins::ModuleGroup[
    TrueClass,
    FalseClass,
    NilClass,
    Numeric,
    Array,
    Hash,
  ]

  # Creates a new Sanitizer.
  #
  # @param sanitize [Proc, nil] a callable that receives a String and
  #   returns a sanitized String, or `nil` to disable sanitization
  def initialize(&sanitize)
    @sanitize = sanitize
  end

  # Sanitizes +value+ if a sanitize proc was configured and the value is
  # not a non-string JSON type.
  #
  # @param value [Object] the value to sanitize
  # @return [Object] the sanitized string, or the original value if
  #   sanitization is disabled or the value is a non-string JSON type
  def sanitize(value)
    @sanitize or return value
    if JSON_NONSTRING_TYPES === value
      value
    else
      @sanitize.(value.to_s)
    end
  end
end
