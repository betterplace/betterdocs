require 'betterdocs/dsl/controller/controller_base'
require 'betterdocs/dsl/common.rb'

class Betterdocs::Dsl::Controller::Action < Betterdocs::Dsl::Controller::ControllerBase
  require 'betterdocs/dsl/controller/action/param'
  require 'betterdocs/dsl/controller/action/response'

  dsl_accessor :action

  alias name action

  dsl_accessor :title do "All about: #{action}" end

  dsl_accessor :section do
    controller.docs.controller.full?(:section) || :misc
  end

  dsl_accessor :action_method

  dsl_accessor :http_method do
    case action
    when :show, :index
      :GET
    when :update
      :PUT
    when :destroy
      :DELETE
    when :create
      :POST
    else
      raise ArgumentError, "Cannot automatically derive http_method for"\
        " #{name.inspect}, specify manually"
    end
  end

  dsl_accessor :params do {} end

  dsl_accessor :json_params_representer

  def json_params_like(klass)
    json_params_representer klass.docs
    self
  end

  def json_params
    json_params_representer.full?(:params)
  end

  def json_params_example_json
    if params = json_params_representer.full?(:params)
      data = {}
      params.each_with_object(data) do |(name, param), d|
        d[name] = param.value
      end
      JSON.pretty_generate(JSON.load(JSON.dump(data)), quirks_mode: true) # sigh, don't ask…
    end
  end

  dsl_accessor :private, false

  def param(name, &block)
    name = name.to_sym
    if block
      param = Betterdocs::Dsl::Controller::Action::Param.new(name, &block)
      param.value or param.value params.size + 1
      params[name] = param
    else
      params[name]
    end
  end

  dsl_accessor :responses do {} end

  def response(name = :default, &block)
    if block
      responses[name] = Betterdocs::Dsl::Controller::Action::Response.new(
        name, &block
      ).set_context(self)
    else
      responses[name]
    end
  end

  dsl_accessor :description, 'TODO'

  def configure_for_action(action_name)
    action action_name
    action_method controller.instance_method(action_name)
  end

  def include_params(callee)
    instance_eval(&callee)
  end

  def url
    url_params = params.select { |_, param| param.use_in_url? }
    Betterdocs.rails.application.routes.url_for(
      {
        controller: controller.name.underscore.sub(/_controller\z/, ''),
        action:     action,
      } | url_params | Betterdocs::Global.config.api_url_options
    )
  end

  def request
    "#{http_method.to_s.upcase} #{url}"
  end

  def to_s
    (
      [ request, '' ] +
      [ inspect, '' ] +
      params.map { |name, param|
        "#{name}(=#{param.value}): #{param.description}"
      } + [ '', description, '', action_method.source_location * ':', '' ]
    ) * "\n"
  end

  def inspect
    "#{controller}##{action}(#{params.keys * ', '})"
  end

  def add_to_collector(collector)
    collector.element = self
  end
end
