module Betterdocs
  # The DSL namespace for Betterdocs. Contains the controller, result,
  # and JSON params DSL modules used for documenting API endpoints.
  module Dsl
  end
end

require 'betterdocs/dsl/controller'
require 'betterdocs/dsl/result'
require 'betterdocs/dsl/json_params'
