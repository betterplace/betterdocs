# Represents a documented response for a controller action. Validates
# that the response data includes {Betterdocs::Responding} and
# provides access to its properties and links for documentation.
class Betterdocs::Dsl::Controller::Action::Response
  include Betterdocs::Dsl::Common
  extend Tins::DSLAccessor

  # Raised when response data is missing, empty, or invalid.
  class Error < StandardError; end

  # Initializes the response with a name and an optional data block.
  #
  # @param name [Symbol] the response name (defaults to `:default`)
  def initialize(name = :default, &block)
    @name = name.to_sym
    @data_block = block || proc {}
  end

  # @!method name
  #
  # @overload name
  #   Returns the name of this response.
  #
  #   @note No default; assigned in `initialize`.
  #   @return [Symbol] the response name
  #
  # @overload name(name)
  #   Sets the response name.
  #
  #   @param name [Symbol] the response name
  #   @return [Symbol] the response name
  dsl_accessor :name

  # Returns a proc that resolves the named param's value.
  #
  # @return [Proc]
  def params
    -> name { param(name).full?(:value) }
  end

  # Evaluates the data block and validates the result. Any exception
  # raised during evaluation or validation is caught and re-raised as an
  # {Error} (with the original class and message preserved in the new
  # message string).
  #
  # @raise [Error] if the result is not `Betterdocs::Responding`, if the
  #   data payload is empty, or if the data block raises any `StandardError`
  # @return [Object] the validated response data
  def data
    @data ||= instance_eval(&@data_block)
    @data.is_a? Betterdocs::Responding or
      raise Error, "result #{@data.class} is not Betterdocs::Responding"
    hash = @data.to_hash
    if hash.key?(:data) && hash[:data].empty?
      raise Error, "result data for action #{controller}##{action} is empty"
    elsif hash.empty?
      raise Error, "result for action #{controller}##{action} is empty"
    end
    @data
  rescue => e
    error = e.is_a?(Error) ? e : Error.new("#{e.class}: #{e}")
    error.set_backtrace e.backtrace.grep(/^#{Betterdocs.rails.root}/)
    raise error
  end

  # Returns the nested properties from the representer's docs.
  #
  # @return [Array] the property list
  def properties
    representer.full? { |r| r.docs.nested_properties }  || []
  end

  # Returns the nested links from the representer's docs.
  #
  # @return [Array] the link list
  def links
    representer.full? { |r| r.docs.nested_links }  || []
  end

  # Returns the representer module for the response data.
  #
  # @return [Module, nil] the representer, or nil if no data available
  def representer
    data or return
    data.ask_and_send(:representer) || inherited_representer(data)
  end

  # Walks the singleton class ancestors to find the first ancestor
  # that includes `Betterdocs::ResultRepresenter` and responds to
  # `:docs`.
  def inherited_representer(data)
    data.singleton_class.ancestors.find { |c|
      Betterdocs::ResultRepresenter >= c && c.respond_to?(:docs)
    }
  end
  private :inherited_representer

  # Serializes the response data to JSON.
  #
  # @raise [Error] if the data is nil
  # @return [String] the JSON representation
  def to_json(*a)
    data.nil? and raise Error, "result for action #{controller}##{action} was nil"
    unless data.is_a?(Betterdocs::Responding)
      infobar.puts "#{data.class}".red
      infobar.puts "Result of type #{data.class} for action #{controller}##{action} is not hash / Betterdocs::Representer"
    end
    data.ask_and_send_or_self(:to_hash).to_json(*a)
  end
end
