require 'simplecov'
require "codeclimate-test-reporter"
if ENV['START_SIMPLECOV'].to_i == 1
  SimpleCov.start do
    add_filter "#{File.basename(File.dirname(__FILE__))}/"
  end
end
if ENV['CODECLIMATE_REPO_TOKEN']
  if ENV['START_SIMPLECOV']
    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      CodeClimate::TestReporter::Formatter
    ]
  end
  CodeClimate::TestReporter.start
end
require 'rspec'
require 'byebug'
require 'betterdocs'
