module Betterdocs
  module JsonTimeWithZone
    def to_json(*)
      iso8601.inspect
    end
  end
end
