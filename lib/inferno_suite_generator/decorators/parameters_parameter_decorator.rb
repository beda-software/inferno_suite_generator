# frozen_string_literal: true

require "fhir_models"

# Decorator class for FHIR::R4::Parameters::Parameter that provides additional
# utility methods for working with parameter parts and extracting values.
class ParametersParameterDecorator < FHIR::R4::Parameters::Parameter
  def initialize(parameter)
    super()
    @parameter = parameter
  end

  def patchset_data
    [{
      op: find_part_by_name("type")&.valueCode,
      path: find_part_by_name("path")&.valueString,
      value: hash_value
    }]
  end

  private

  def find_part_by_name(name)
    return nil if parameter_part_empty?

    @parameter.part.find { |part_item| part_item.name == name }
  end

  def parameter_part_empty?
    @parameter.part.empty?
  end

  def hash_value
    value_hash = find_part_by_name("value")&.source_hash
    value_key = value_hash&.keys&.find { |key| key != "name" }
    value_key ? value_hash[value_key] : nil
  end
end
