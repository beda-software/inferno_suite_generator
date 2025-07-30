# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "basic_test_generator"
require_relative "../utils/registry"

module InfernoSuiteGenerator
  class Generator
    class ProvenanceRevincludeSearchTestGenerator < BasicTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          ig_metadata.groups
                     .reject do |group|
                       config = Registry.get(:config_keeper)
                       config.resources_to_exclude.include?(group.resource)
                     end
                     .select { |group| group.revincludes.include? "Provenance:target" }
                     .each { |group| new(group, group.searches.first, base_output_dir, ig_metadata).generate }
        end
      end

      attr_accessor :group_metadata, :search_metadata, :base_output_dir, :ig_metadata

      self.template_type = TEMPLATE_TYPES[:PROVENANCE_REVINCLUDE_SEARCH]

      def initialize(group_metadata, search_metadata, base_output_dir, ig_metadata)
        self.group_metadata = group_metadata
        self.search_metadata = search_metadata
        self.base_output_dir = base_output_dir
        self.ig_metadata = ig_metadata
      end

      def search_identifier
        "provenance_revinclude"
      end

      def search_title
        search_identifier.camelize
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

      def first_search?
        group_metadata.searches.first == search_metadata
      end

      def fixed_value_search?
        search_metadata[:names] != ["patient"] &&
          !group_metadata.delayed? && resource_type != "Patient"
      end

      def fixed_value_search_param_name
        (search_metadata[:names] - [:patient]).first
      end

      def search_param_name_string
        "#{search_metadata[:names].join(" + ")} + revInclude:Provenance:target"
      end

      def needs_patient_id?
        search_metadata[:names].include?("patient") ||
          (resource_type == "Patient" && search_metadata[:names].include?("_id"))
      end

      def search_param_names
        search_params.map { |param| param[:name] }
      end

      def search_param_names_array
        array_of_strings(search_param_names)
      end

      def path_for_value(path)
        path == "class" ? "local_class" : path
      end

      def required_comparators_for_param(name)
        search_definition(name)[:comparators].select { |_comparator, expectation| expectation == "SHALL" }
      end

      def required_comparators
        @required_comparators ||=
          search_param_names.each_with_object({}) do |name, comparators|
            required_comparators = required_comparators_for_param(name)
            comparators[name] = required_comparators if required_comparators.present?
          end
      end

      # def patient_id_param?(param)
      #   param[:name] == 'patient' ||
      #     (resource_type == 'Patient' && param[:name] == '_id')
      # end

      def search_definition(name)
        group_metadata.search_definitions[name.to_sym]
      end

      def saves_delayed_references?
        first_search? && group_metadata.delayed_references.present?
      end

      def possible_status_search?
        !search_metadata[:names].include?("status") && group_metadata.search_definitions.key?(:status)
      end

      def token_search_params
        @token_search_params ||=
          search_param_names.select do |name|
            %w[Identifier CodeableConcept Coding].include? group_metadata.search_definitions[name.to_sym][:type]
          end
      end

      def token_search_params_string
        array_of_strings(token_search_params)
      end

      def required_comparators_string
        array_of_strings(required_comparators.keys)
      end

      def array_of_strings(array)
        quoted_strings = array.map { |element| "'#{element}'" }
        "[#{quoted_strings.join(", ")}]"
      end

      def search_properties
        {}.tap do |properties|
          properties[:fixed_value_search] = "true" if fixed_value_search?
          properties[:resource_type] = "'#{resource_type}'"
          properties[:search_param_names] = search_param_names_array
          properties[:possible_status_search] = "true" if possible_status_search?
        end
      end

      def search_test_properties_string
        search_properties
          .map { |key, value| "#{" " * 8}#{key}: #{value}" }
          .join(",\n")
      end
    end
  end
end
