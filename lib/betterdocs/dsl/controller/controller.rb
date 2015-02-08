require 'betterdocs/dsl/controller/controller_base'

class Betterdocs::Dsl::Controller::Controller < Betterdocs::Dsl::Controller::ControllerBase
  def name
    @name ||= controller.to_s.underscore.sub(/_controller\z/, '').to_sym
  end

  dsl_accessor :section

  dsl_accessor :description, 'TODO'

  def url
    Betterdocs::Global.url_for(
      controller: name,
      action: :index,
      format: 'json'
    )
  end

  def url_helpers
    Betterdocs::Global.url_helpers
  end

  def to_s
    [ controller, '', "url: #{url}", '', description, '' ] * "\n"
  end

  def add_to_collector(collector)
    collector.controller = self
  end
end
