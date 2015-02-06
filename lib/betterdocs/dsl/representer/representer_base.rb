class Betterdocs::Dsl::Representer::RepresenterBase
  def initialize(representer, name, options, &block)
    set_context @representer = representer
    @name = name.to_sym
    @options = options | {
      if:      -> { true },
      unless:  -> { false },
    }
    block and instance_eval(&block)
  end

  attr_reader :name

  attr_reader :representer

  def assign?(object)
    object.instance_exec(&(@options[:if])) &&
      !object.instance_exec(&(@options[:unless]))
  end

  def assign(result, object)
    raise NotImplementedError, 'assign needs to be implemented in subclass'
  end

  def add_to_collector(collector)
    raise NotImplementedError, 'add_to_collector needs to be implemented in subclass'
  end
end

