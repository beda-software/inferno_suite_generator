# frozen_string_literal: true

module InfernoSuiteGenerator
  # Provides generic helper methods for generators
  module GeneratorUtils
    def search_test_properties_string
      search_properties
        .map { |key, value| "#{" " * 8}#{key}: #{value}" }
        .join(",\n")
    end

    def required_comparators
      @required_comparators ||=
        search_param_names.each_with_object({}) do |name, comparators|
          required_comparators = required_comparators_for_param(name)
          comparators[name] = required_comparators if required_comparators.present?
        end
    end

    def token_search_params
      @token_search_params ||=
        search_param_names.select do |name|
          %w[Identifier CodeableConcept Coding].include? group_metadata.search_definitions[name.to_sym][:type]
        end
    end

    def search_params
      @search_params ||=
        search_metadata[:names].map do |name|
          {
            name:,
            path: search_definition(name)[:path]
          }
        end
    end
  end
end
