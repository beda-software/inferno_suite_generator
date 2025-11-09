# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "search_test_generator"
require_relative "../utils/helpers"
require_relative "../utils/registry"
require_relative "../utils/multiple_or_search_test_generator_helpers"

module InfernoSuiteGenerator
  class Generator
    # The MultipleOrSearchTestGenerator class generates test files for search FHIR resources.
    # It extends SearchTestGenerator and handles the generation of test files specifically
    # for testing multiple OR search operations against a FHIR server.
    class MultipleOrSearchTestGenerator < SearchTestGenerator
      include MultipleOrSearchTestGeneratorHelpers

      class << self
        def generate(ig_metadata, base_output_dir)
          ig_metadata.groups
                     .select { |group| group.searches.present? }
                     .each do |group|
            group.search_definitions.each_key do |search_key|
              if multiple_or_test?(group, search_key)
                new(search_key.to_s, group, group.search_definitions[search_key], base_output_dir,
                    ig_metadata).generate
              end
            end
          end
        end

        def multiple_or_test?(group, search_key)
          group.search_definitions[search_key].key?(:multiple_or) && search_key.to_s != "patient"
        end
      end

      attr_accessor :search_name, :group_metadata, :search_metadata, :base_output_dir, :ig_metadata

      self.template_type = TEMPLATE_TYPES[:MULTIPLE_OR_SEARCH]

      def initialize(search_name, group_metadata, search_metadata, base_output_dir, ig_metadata)
        super(group_metadata, search_metadata, base_output_dir, ig_metadata)
        self.search_name = search_name
      end

      def search_identifier
        search_name.to_s.tr("-", "_")
      end

      def search_title
        search_identifier
      end

      def conformance_expectation
        # NOTE: https://github.com/hl7au/au-fhir-core-inferno/issues/61
        return "SHOULD" if search_name == "status" && %w[Procedure Observation].include?(resource_type)

        search_metadata[:multiple_or]
      end

      def first_search?
        group_metadata.searches.first == search_metadata
      end

      def fixed_value_search?
        first_search? && search_metadata[:names] != ["patient"] &&
          !group_metadata.delayed? && resource_type != "Patient"
      end

      def fixed_value_search_param_name
        (search_metadata[:names] - [:patient]).first
      end

      def search_param_name_string
        search_name
      end

      def needs_patient_id?
        true
      end

      def search_param_names
        [search_name]
      end

      def search_param_names_array
        array_of_strings(search_param_names)
      end

      def path_for_value(path)
        path == "class" ? "local_class" : path
      end

      def optional?
        %w[SHOULD MAY].include?(conformance_expectation)
      end

      def search_definition(name)
        group_metadata.search_definitions[name.to_sym]
      end

      def saves_delayed_references?
        first_search? && group_metadata.delayed_references.present?
      end

      def required_multiple_or_search_params
        @required_multiple_or_search_params ||=
          search_definition(search_name)[:multiple_or] == "SHALL"
      end

      def optional_multiple_or_search_params
        @optional_multiple_or_search_params ||=
          search_definition(search_name)[:multiple_or] == "SHOULD"
      end

      def required_multiple_or_search_params_string
        required_multiple_or_search_params
      end

      def optional_multiple_or_search_params_string
        optional_multiple_or_search_params
      end

      def required_comparators_string
        array_of_strings(required_comparators.keys)
      end

      def array_of_strings(array)
        quoted_strings = array.map { |element| "'#{element}'" }
        "[#{quoted_strings.join(", ")}]"
      end

      def test_reference_variants?
        first_search? && search_param_names.include?("patient")
      end

      def test_medication_inclusion?
        %w[MedicationRequest MedicationDispense].include?(resource_type)
      end

      def test_post_search?
        first_search?
      end
    end
  end
end
