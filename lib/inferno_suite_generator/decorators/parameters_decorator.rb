# frozen_string_literal: true

require "fhir_models"
require_relative "parameters_parameter_decorator"

# Decorator class for FHIR::R4::Parameters that provides additional
# utility methods for working with parameter parts and extracting values.
class ParametersDecorator < FHIR::R4::Parameters
  def initialize(parameters)
    super()
    @parameters = parameters
  end

  def to_json_patch
    return [] unless @parameters.parameter

    json_patch_operations = []

    @parameters.parameter.each do |param|
      json_patch_operations += ParametersParameterDecorator.new(param).patchset_data
    end

    json_patch_operations
  end

  private
end
