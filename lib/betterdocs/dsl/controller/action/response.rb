class Betterdocs::Dsl::Controller::Action::Response
  include Betterdocs::Dsl::Common
  extend Tins::DSLAccessor

  class Error < StandardError; end

  def initialize(name = :default, &block)
    @name = name.to_sym
    @data_block = block || proc {}
  end

  dsl_accessor :name

  def params
    -> name { param(name).full?(:value) }
  end

  def data
    @data ||= instance_eval(&@data_block)
  rescue => e
    error = Error.new("#{e.class}: #{e}")
    error.set_backtrace e.backtrace.grep(/^#{Betterdocs.rails.root}/)
    raise error
  end

  def properties
    representer.full? { |r| r.docs.nested_properties }  || []
  end

  def links
    representer.full? { |r| r.docs.nested_links }  || []
  end

  def representer
    data or return
    data.ask_and_send(:representer) || inherited_representer(data)
  end

  private\
  def inherited_representer(data)
    data.singleton_class.ancestors.find { |c|
      Betterdocs::ResultRepresenter >= c && c.respond_to?(:docs)
    }
  end

  def to_json(*a)
    my_data = data.ask_and_send(:to_hash) || data
    my_data.to_json(*a)
  end
end
