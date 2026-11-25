require 'tins/xt'
require 'mize'
require 'rails'

# Document-as-code gem for generating Markdown and OpenAPI 3.0.2
# documentation from Ruby DSL annotations on Rails API controllers
# and response objects.
#
# @see Betterdocs::Global
# @see Betterdocs::Representer
module Betterdocs
  class << self
    # Returns the top-level `::Rails` module.
    #
    # @return [Module] the `Rails` module
    def rails
      ::Rails
    end

    # Alias of `proc`, exposed for DSL readability in documentation blocks.
    alias trait proc
    public :trait
  end
end

require 'betterdocs/version'
require 'betterdocs/responding'
require 'betterdocs/dsl'
require 'betterdocs/sanitizer'
require 'betterdocs/representer'
require 'betterdocs/result_representer'
require 'betterdocs/result_representer_collector'
require 'betterdocs/controller_collector'
require 'betterdocs/json_params_representer_collector'
require 'betterdocs/json_params_representer'
require 'betterdocs/global'
require 'betterdocs/section'
require 'betterdocs/mix_into_controller'
require 'betterdocs/generator/config_shortcuts'
require 'betterdocs/generator/markdown'
require 'betterdocs/generator/swagger'
require 'betterdocs/json_time_with_zone'
defined? Rails and require 'betterdocs/railtie'
