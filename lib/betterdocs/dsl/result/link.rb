require 'betterdocs/dsl/representer'
require 'betterdocs/dsl/common'
require 'betterdocs/dsl/naming'

class Betterdocs::Dsl::Result::Link < Betterdocs::Dsl::Representer
  extend Tins::DSLAccessor
  include Betterdocs::Dsl::Common
  include Betterdocs::Dsl::Naming

  dsl_accessor :description, 'TODO'

  dsl_accessor :templated, false

  def url(&block)
    if block
      @url = block
    elsif @url
      @url
    else
      raise ArgumentError, 'link requires an URL'
    end
  end

  def assign(result, object)
    assign?(object) or return
    link = {
      'rel'  => name.to_s,
      'href' => object.instance_eval(&url).to_s,
    }
    templated and link['templated'] = true
    result['links'].push(link)
    self
  end

  def add_to_collector(collector)
    collector.links[name] = self
  end
end
