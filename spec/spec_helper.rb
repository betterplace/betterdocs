require 'simplecov'
if ENV['START_SIMPLECOV'].to_i == 1
  SimpleCov.start do
    add_filter "#{File.basename(File.dirname(__FILE__))}/"
  end
end
require 'rspec'
require 'byebug'
require 'betterdocs'
