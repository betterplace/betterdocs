require 'tins/xt'
require 'rails'

module Betterdocs
  require 'betterdocs/version'
  require 'betterdocs/representer'
  require 'betterdocs/dsl'
  require 'betterdocs/controller_collector'
  require 'betterdocs/representer_collector'
  require 'betterdocs/json_type_mapper'
  require 'betterdocs/global'
  require 'betterdocs/section'
  require 'betterdocs/mix_into_controller'
  require 'betterdocs/generator/config_shortcuts'
  require 'betterdocs/generator/markdown'
  require 'betterdocs/rake_tasks'

  def self.rails
    ::Rails
  end
end
