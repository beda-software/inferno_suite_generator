# frozen_string_literal: true

module InfernoSuiteGenerator
  # Provides helper methods for generating "OR" search tests within the InfernoSuiteGenerator.
  module MultipleOrSearchTestGeneratorHelpers
    def simple_search_test_configs
      [
        { property: :first_search, value: "true", if: first_search? },
        { property: :fixed_value_search, value: "true", if: fixed_value_search? },
        { property: :resource_type, value: "'#{resource_type}'", if: true },
        { property: :search_param_names, value: search_param_names, if: true },
        { property: :saves_delayed_references, value: "true", if: saves_delayed_references? },
        { property: :test_medication_inclusion, value: "true", if: test_medication_inclusion? },
        { property: :test_reference_variants, value: "true", if: test_reference_variants? }
      ]
    end

    def complex_search_test_configs
      [
        { property: :multiple_or_search_params, value: required_multiple_or_search_params_string,
          if: required_multiple_or_search_params.present? },
        { property: :optional_multiple_or_search_params, value: optional_multiple_or_search_params_string,
          if: optional_multiple_or_search_params.present? },
        { property: :search_by_target_resource_data, value: "true", if: search_by_target_resource? }
      ]
    end

    def search_by_target_resource?
      Registry.get(:config_keeper).multiple_or_and_search_by_target_resource?(
        group_metadata.profile_url, resource_type, search_param_names
      )
    end

    def search_test_hash_config
      simple_search_test_configs + complex_search_test_configs
    end

    def search_properties
      {}.tap do |properties|
        search_test_hash_config.each do |config|
          properties[config[:property]] = config[:value] if config[:if]
        end
      end
    end

    def search_test_properties_string
      search_properties
        .map { |key, value| "#{" " * 8}#{key}: #{value}" }
        .join(",\n")
    end

    def description
      Helpers.multiple_test_description("OR", conformance_expectation, search_param_name_string, resource_type,
                                        url_version)
    end
  end
end
