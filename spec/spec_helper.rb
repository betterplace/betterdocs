require 'gem_hadar/simplecov'
GemHadar::SimpleCov.start
require 'rspec'
require 'debug'
require 'ostruct'
require 'betterdocs'

RSpec.configure do |c|
  c.before do
    ComplexConfig::Provider.config_dir = 'spec/assets/config'
    Betterdocs::Global.configure
  end
end

