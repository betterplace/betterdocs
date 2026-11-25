module Betterdocs
  # Extends time objects with JSON serialization that outputs
  # ISO 8601 strings instead of the default epoch timestamp.
  module JsonTimeWithZone
    # Serializes the receiver to a JSON string using its ISO 8601
    # representation instead of the default epoch timestamp.
    #
    # @return [String] the ISO 8601 string, quoted for JSON
    def to_json(*)
      iso8601.inspect
    end
  end
end
