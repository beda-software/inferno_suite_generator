# frozen_string_literal: true

require_relative 'search_definition_metadata_extractor'

module InfernoSuiteGenerator
  class Generator
    class SearchMetadataExtractor
      COMBO_EXTENSION_URL =
        'http://hl7.org/fhir/StructureDefinition/capabilitystatement-search-parameter-combination'

      attr_accessor :resource_capabilities, :ig_resources, :profile_elements, :group_metadata

      def initialize(resource_capabilities, ig_resources, profile_elements, group_metadata)
        self.resource_capabilities = resource_capabilities
        self.ig_resources = ig_resources
        self.profile_elements = profile_elements
        self.group_metadata = group_metadata
      end

      def searches
        @searches ||= basic_searches + combo_searches

        handle_special_cases

        @searches
      end

      def conformance_expectation(search_param)
        search_param.extension.first.valueCode # TODO: fix expectation extension finding
      end

      def no_search_params?
        resource_capabilities.searchParam.blank?
      end

      def basic_searches
        return [] if no_search_params?
        search_parameters = resource_capabilities.searchParam
        filtered_search_parameters = filter_search_params_with_expectation(search_parameters)
        filtered_search_parameters = remove_excluded_search_params(filtered_search_parameters)

        filtered_search_parameters.map do |search_param|
          {
            names: [search_param.name],
            expectation: conformance_expectation(search_param)
          }
        end
      end

      def search_extensions
        resource_capabilities.extension
      end

      def combo_searches
        return [] if search_extensions.blank?
        combo_search_params = search_extensions
                                .select { |extension| extension.url == COMBO_EXTENSION_URL }
                                .select { |extension| %w[SHALL SHOULD MAY].include? conformance_expectation(extension) }
                                .map do |extension|
          names = extension.extension.select { |param| param.valueString.present? }.map(&:valueString)
          {
            expectation: conformance_expectation(extension),
            names: names
          }
        end

        combo_search_params.reject do |combo_search_param|
          # TODO: Move to the config
          combo_search_param[:names].any? { |sp| %w[_count _sort _include].include? sp }
        end
      end

      def search_param_names
        searches.flat_map { |search| search[:names] }.uniq
      end

      def search_definitions
        search_param_names.each_with_object({}) do |name, definitions|
          definitions[name.to_sym] =
            SearchDefinitionMetadataExtractor.new(name, ig_resources, profile_elements,
                                                  group_metadata).search_definition
        end
      end

      def handle_special_cases
        # TODO: Add to config
        # NOTE: https://github.com/hl7au/au-fhir-core-inferno/issues/57
        profile_url = group_metadata[:profile_url]
        if profile_url == 'http://hl7.org.au/fhir/core/StructureDefinition/au-core-medicationrequest'
          @searches.map do |search|
            if search[:names] == ["patient", "intent", "authoredon"] && search[:expectation] == "SHALL"
              search[:expectation] = "SHOULD"
            end
          end
        end
      end

      private

      def filter_search_params_with_expectation(search_params)
        search_params.select do |search_param|
          %w[SHALL SHOULD MAY].include? conformance_expectation(search_param)
        end
      end

      def remove_excluded_search_params(search_params)
        # TODO: Add to the config
        search_params.select do |search_param|
          !%w[_count _sort _include].include? search_param.name
        end
      end
    end
  end
end
