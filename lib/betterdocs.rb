require 'tins/xt'
require 'rails'

module Betterdocs
  def self.rails
    ::Rails
  end
end

require 'betterdocs/version'
require 'betterdocs/dsl'
require 'betterdocs/representer'
require 'betterdocs/controller_collector'
require 'betterdocs/representer_collector'
require 'betterdocs/global'
require 'betterdocs/section'
require 'betterdocs/mix_into_controller'
require 'betterdocs/generator/config_shortcuts'
require 'betterdocs/generator/markdown'
require 'betterdocs/rake_tasks'
