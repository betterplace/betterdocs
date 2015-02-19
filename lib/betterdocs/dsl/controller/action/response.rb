class Betterdocs::Dsl::Controller::Action::Response
  include Betterdocs::Dsl::Common
  extend Tins::DSLAccessor

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
  end

  def properties
    representer.full? { |r| r.docs.nested_properties }  || []
  end

  def links
    representer.full? { |r| r.docs.nested_links }  || []
  end

  def representer
    if data
      data.ask_and_send(:representer) ||
        data.singleton_class.ancestors.find { |c|
        Betterdocs::ResultRepresenter >= c && c.respond_to?(:docs)
        # Actually it's more like
        #   Betterdocs::ResultRepresenter >= c && !c.singleton_class?
        # in newer rubies.
        # But singleton_class? is broken and private in ruby 2.1.x not
        # existant in <= ruby 2.0.x and finally works in ruby 2.2.x.
        # What a mess!
      }
    end
  end

  def to_json(*)
    JSON.pretty_generate(JSON.load(JSON.dump(data)), quirks_mode: true) # sigh, don't ask…
  rescue TypeError => e
    STDERR.puts "Caught #{e}: #{e.message} for #{data.inspect}"
    nil
  end
end
