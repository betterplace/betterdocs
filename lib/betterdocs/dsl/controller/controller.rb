require 'betterdocs/dsl/controller/controller_base'

# DSL element representing a documented API controller. Wraps a
# real Rails controller class and collects its metadata (section,
# description, URL) for the documentation generators.
class Betterdocs::Dsl::Controller::Controller < Betterdocs::Dsl::Controller::ControllerBase
  # Returns the underscored controller name (without the
  # `Controller` suffix) as a frozen Symbol.
  #
  # @return [Symbol] e.g. `:things`
  def name
    @name ||= controller.to_s.underscore.sub(/_controller\z/, '').to_sym
  end

  # @!method section
  #
  # @overload section
  #   Returns the documentation section this controller belongs to.
  #
  #   @note Returns `nil` until set.
  #   @return [Symbol] the section identifier
  #
  # @overload section(name)
  #   Sets the section.
  #
  #   @param name [Symbol] the section identifier
  #   @return [Symbol] the section identifier
  dsl_accessor :section

  # @!method description
  #
  # @overload description
  #   Returns a human-readable description of the controller's purpose.
  #
  #   @note Defaults to `"TODO"`.
  #   @return [String] the controller description
  #
  # @overload description(description)
  #   Sets the controller description.
  #
  #   @param description [String] the description
  #   @return [String] the description
  dsl_accessor :description, 'TODO'

  # Generates the base URL for this controller's `index` action.
  #
  # @return [String] the absolute URL
  def url
    Betterdocs::Global.url_for(
      controller: name,
      action: :index,
      format: 'json'
    )
  end

  # Returns the Rails URL helpers module.
  #
  # @return [Module] `Betterdocs::Global.url_helpers`
  def url_helpers
    Betterdocs::Global.url_helpers
  end

  # Renders a multi-line summary of this controller for plain-text
  # output.
  #
  # @return [String] controller name, URL, and description
  def to_s
    [ controller, '', "url: #{url}", '', description, '' ] * "\n"
  end

  # Registers this controller element with the given collector.
  #
  # @param collector [Betterdocs::ControllerCollector] the target
  def add_to_collector(collector)
    collector.controller = self
  end
end
