module Betterdocs
  # Marker module for objects that can appear in API responses.
  #
  # Purely an identity check — the module itself is empty. Include it in
  # result modules (e.g. `ResultSet`) or extend a plain object with it
  # (`object.extend(Betterdocs::Responding)`) so that
  # {Betterdocs::Dsl::Controller::Action::Response} can verify via
  # `is_a? Betterdocs::Responding` that the response data is a valid
  # serializable object.
  module Responding
  end
end
