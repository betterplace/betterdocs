module Betterdocs
  module Dsl
    # Namespace for the controller documentation DSL. Provides the
    # {Controller} and {Action} classes used to describe API endpoints.
    module Controller
    end
  end
end

require 'betterdocs/dsl/controller/action'
require 'betterdocs/dsl/controller/controller'
