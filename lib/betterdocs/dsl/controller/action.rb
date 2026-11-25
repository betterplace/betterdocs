require 'betterdocs/dsl/controller/controller_base'
require 'betterdocs/dsl/common.rb'

# A documented controller action. Wraps a Rails controller method and
# collects its request/response metadata (HTTP method, params, JSON
# params, responses, description) for the documentation generators.
class Betterdocs::Dsl::Controller::Action < Betterdocs::Dsl::Controller::ControllerBase
  require 'betterdocs/dsl/controller/action/param'
  require 'betterdocs/dsl/controller/action/response'

  # @!method action
  #
  # @overload action
  #   Returns the name of the controller action being documented. Also
  #   exposed as the `name` alias.
  #
  #   @note Returns `nil` until set.
  #   @return [Symbol] the action name
  #
  # @overload action(name)
  #   Sets the action name.
  #
  #   @param name [Symbol] the action name
  #   @return [Symbol] the action name
  dsl_accessor :action

  alias name action

  # @!method title
  #
  # @overload title
  #   Returns the documentation title for this action.
  #
  #   @note No explicit value set, so the default block is re-evaluated
  #     on each read: `"All about: \#{action}"`.
  #   @return [String] the title
  #
  # @overload title(title)
  #   Sets the documentation title.
  #
  #   @param title [String] the title
  #   @return [String] the title
  dsl_accessor :title do "All about: #{action}" end

  # @!method section
  #
  # @overload section
  #   Returns the documentation section for this action.
  #
  #   @note No explicit value set, so the default block is re-evaluated
  #     on each read: the controller's documented section, falling back
  #     to `:misc`.
  #   @return [Symbol] the section identifier
  #
  # @overload section(name)
  #   Explicitly sets the section, overriding the derived default.
  #
  #   @param name [Symbol] the section identifier
  #   @return [Symbol] the section identifier
  dsl_accessor :section do
    controller.docs.controller.full?(:section) || :misc
  end

  # @!method action_method
  #
  # @overload action_method
  #   Returns the `UnboundMethod` of the controller action.
  #
  #   @note Returns `nil` until set by `configure_for_action`.
  #   @return [UnboundMethod] the controller action method
  #
  # @overload action_method(method)
  #   Sets the controller action method.
  #
  #   @param method [UnboundMethod] the method
  #   @return [UnboundMethod] the method
  dsl_accessor :action_method

  # @!method http_method
  #
  # @overload http_method
  #   Returns the HTTP method for this action.
  #
  #   @note No explicit value set, so the default block is re-evaluated
  #     on each read: derived from the action name (`:show`/`:index` →
  #     `:GET`, `:create` → `:POST`, `:update` → `:PUT`,
  #     `:destroy` → `:DELETE`).
  #   @return [Symbol] the HTTP method
  #   @raise [ArgumentError] if the action name does not map to a
  #     known HTTP method and no explicit value was set
  #
  # @overload http_method(method)
  #   Explicitly sets the HTTP method, overriding the derived default.
  #
  #   @param method [Symbol] the HTTP method
  #   @return [Symbol] the HTTP method
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

  # @!method params
  #
  # @overload params
  #   Returns the map of request parameters for this action.
  #
  #   @note No explicit value set, so the default block is re-evaluated
  #     on each read: an empty hash.
  #   @return [Hash{Symbol => Param}] the params
  #
  # @overload params(params)
  #   Sets the request parameters map.
  #
  #   @param params [Hash] the params map
  #   @return [Hash] the params map
  dsl_accessor :params do {} end

  # @!method json_params_representer
  #
  # @overload json_params_representer
  #   Returns the documented JSON params representer for this action.
  #
  #   @note Returns `nil` until set by `json_params_like`.
  #   @return [Object, nil] the JSON params representer
  #
  # @overload json_params_representer(representer)
  #   Sets the JSON params representer.
  #
  #   @param representer [Object] the representer
  #   @return [Object] the representer
  dsl_accessor :json_params_representer

  # Points this action's JSON params at another class's documented params.
  #
  # @param klass [Class] a class responding to `docs`
  # @return [self]
  def json_params_like(klass)
    json_params_representer klass.docs
    self
  end

  # Returns the documented JSON params (name/param hash) or nil.
  #
  # @return [Hash, nil]
  def json_params
    json_params_representer.full?(:params)
  end

  # Returns the JSON params rendered as a pretty-printed example document.
  #
  # @return [String, nil] JSON string, or nil if no params are documented
  def json_params_example_json
    if params = json_params_representer.full?(:params)
      data = {}
      params.each_with_object(data) do |(name, param), d|
        d[name] = param.value
      end
      JSON.pretty_generate(JSON.load(JSON.dump(data)), quirks_mode: true) # sigh, don't ask…
    end
  end

  # @!method private
  #
  # @overload private
  #   Returns whether this action is hidden from the generated
  #   documentation.
  #
  #   @note Defaults to `false`.
  #   @return [Boolean] true if the action is private
  #
  # @overload private(flag)
  #   Sets whether the action is hidden from the documentation.
  #
  #   @param flag [Boolean] the flag
  #   @return [Boolean] the flag
  dsl_accessor :private, false

  # Defines or reads a request parameter of this action.
  #
  # @param name [Symbol] the parameter name
  # @yield the DSL block configuring the param (when defining)
  # @return [Betterdocs::Dsl::Controller::Action::Param] the param
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

  # @!method responses
  #
  # @overload responses
  #   Returns the map of documented responses for this action.
  #
  #   @note No explicit value set, so the default block is re-evaluated
  #     on each read: an empty hash.
  #   @return [Hash{Symbol => Response}] the responses
  #
  # @overload responses(responses)
  #   Sets the documented responses map.
  #
  #   @param responses [Hash] the responses map
  #   @return [Hash] the responses map
  dsl_accessor :responses do {} end

  # Defines or reads a response of this action.
  #
  # @param name [Symbol] the response name (defaults to `:default`)
  # @yield the DSL block configuring the response (when defining)
  # @return [Betterdocs::Dsl::Controller::Action::Response] the response
  def response(name = :default, &block)
    if block
      responses[name] = Betterdocs::Dsl::Controller::Action::Response.new(
        name, &block
      ).set_context(self)
    else
      responses[name]
    end
  end

  # @!method description
  #
  # @overload description
  #   Returns the documentation description for this action.
  #
  #   @note Defaults to `"TODO"`.
  #   @return [String] the description
  #
  # @overload description(description)
  #   Sets the documentation description.
  #
  #   @param description [String] the description
  #   @return [String] the description
  dsl_accessor :description, 'TODO'

  # Binds this action to the named controller method.
  #
  # @param action_name [Symbol] the controller method to document
  def configure_for_action(action_name)
    action action_name
    action_method controller.instance_method(action_name)
  end

  # Evaluates the given block to define a shared group of params.
  #
  # @param callee [Proc] a block defining params via `param`
  def include_params(callee)
    instance_eval(&callee)
  end

  # Generates the absolute URL for this action.
  #
  # @raise [ActionController::UrlGenerationError] with context if the URL
  #   cannot be generated from the documented params
  # @return [String] the URL
  def url
    url_params = params.select { |_, param| param.use_in_url? }
    url_params = {
      controller: controller.name.underscore.sub(/_controller\z/, ''),
      action:     action,
    } | url_params | Betterdocs::Global.config.api_url_options
    Betterdocs.rails.application.routes.url_for(url_params)
  rescue ActionController::UrlGenerationError => e
    raise e, "Could not generate URL for parameters #{url_params}. Check your param definitions!"
  end

  # Returns the full request line (HTTP method and URL).
  #
  # @return [String] e.g. `GET https://host/api/v1/things.json`
  def request
    "#{http_method.to_s.upcase} #{url}"
  end

  # Renders a multi-line plain-text summary of this action (request, params,
  # description, and the action method's source location).
  #
  # @return [String]
  def to_s
    (
      [ request, '' ] +
      [ inspect, '' ] +
      params.map { |name, param|
        "#{name}(=#{param.value}): #{param.description}"
      } + [ '', description, '', action_method.source_location * ':', '' ]
    ) * "\n"
  end

  # Returns a compact human-readable identifier for this action.
  #
  # @return [String] e.g. `ThingsController#show(id)`
  def inspect
    "#{controller}##{action}(#{params.keys * ', '})"
  end

  # Registers this action element with the given collector.
  #
  # @param collector [Betterdocs::ControllerCollector] the target
  def add_to_collector(collector)
    collector.element = self
  end
end
