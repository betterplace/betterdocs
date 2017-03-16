require 'tins/xt'
require 'mize'
require 'rails'

module Betterdocs
  class << self
    def rails
      ::Rails
    end

    alias trait proc
    public :trait
  end
end

require 'betterdocs/version'
require 'betterdocs/dsl'
require 'betterdocs/sanitizer'
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
require 'betterdocs/rake_tasks'
require 'betterdocs/json_time_with_zone'
defined? Rails and require 'betterdocs/railtie'
