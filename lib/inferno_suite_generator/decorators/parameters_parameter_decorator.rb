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
    {
      op: normalize_operation(find_part_by_name("type")&.valueCode),
      path: convert_fhirpath_to_json_pointer(find_part_by_name("path")&.valueString),
      value: hash_value
    }
  end

  private

  def normalize_operation(fhirpath_op)
    case fhirpath_op&.downcase
    when "add"
      "add"
    when "replace"
      "replace"
    when "remove", "delete"
      "remove"
    when "test"
      "test"
    when "move"
      "move"
    when "copy"
      "copy"
    end
  end

  def convert_fhirpath_to_json_pointer(fhirpath_string)
    return "" unless fhirpath_string

    parts = fhirpath_string.split(".")
    parts = parts.drop(1) if parts.length > 1
    path = parts.join("/")
    path = path.gsub(/\[(\d+)\]/, '/\1')
    path = path.tr(".", "/")
    path = "/#{path}" unless path.start_with?("/")

    path
  end

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
