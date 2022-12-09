# This module should be included in all objects used in an API response which
# should implement a #to_hash method.
module Betterdocs
  module Responding
    implement :to_hash, :submodule
  end
end
