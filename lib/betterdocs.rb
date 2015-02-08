require 'tins/xt'
require 'rails'

module Betterdocs
  def self.rails
    ::Rails
  end
end

require 'betterdocs/version'
require 'betterdocs/dsl'
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
