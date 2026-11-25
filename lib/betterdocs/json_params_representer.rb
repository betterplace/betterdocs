# DSL module for annotating JSON request parameter objects.
#
# Include this module in your param representer classes to declare
# documented parameters that are also assigned to result objects.
#
# @example Defining a documented param set
#   module UserParams
#     include Betterdocs::JsonParamsRepresenter
#
#     param :email do
#       description 'User email'
#       types String
#     end
#   end
module Betterdocs::JsonParamsRepresenter
  extend ActiveSupport::Concern
  include Betterdocs::Representer

  # Class-level methods available to modules including this concern.
  module ClassMethods
    # Returns an empty `HashWithIndifferentAccess` as the default
    # result object for param assignment.
    #
    # @return [HashWithIndifferentAccess]
    def build_result_object
      {}.with_indifferent_access
    end

    # Converts the receiver to a hash, then assigns all documented
    # params onto the result hash from the source object.
    #
    # @param object [Object] the source object
    # @yield [result] yields the result hash for param assignment
    # @yieldparam result [HashWithIndifferentAccess]
    def hashify(object)
      super do |result|
        assign_params result, object
      end
    end

    # Returns the documentation collector for this representer.
    #
    # @return [Betterdocs::JsonParamsRepresenterCollector]
    def docs
      @docs ||= Betterdocs::JsonParamsRepresenterCollector.new
    end

    # Assigns each documented param's value from +object+ into +result+.
    #
    # @param result [HashWithIndifferentAccess] the target hash
    # @param object [Object] the source object to read values from
    def assign_params(result, object)
      for param in params
        param.assign(result, object)
      end
    end
    private :assign_params

    # Returns the set of all documented params.
    #
    # @return [Set<Betterdocs::Dsl::JsonParams::Param>]
    def params
      @params ||= Set.new
    end

    # Declares a documented parameter.
    #
    # @param name [Symbol] the parameter name
    # @param options [Hash] keyword options forwarded to the DSL
    # @yield documentation block for the param
    # @return [self]
    def param(name, **options, &block)
      d = doc(:param, name, **options, &block) and
        params << d
      self
    end
  end
end
