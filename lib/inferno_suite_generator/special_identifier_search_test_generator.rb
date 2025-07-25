# frozen_string_literal: true

require_relative 'naming'
require_relative 'special_cases'
require_relative 'search_test_generator'

module InfernoSuiteGenerator
  class Generator
    class SpecialIdentifierSearchTestGenerator < SearchTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          ig_metadata.groups.reject do |group|
            version_specific_resources = SpecialCases::VERSION_SPECIFIC_RESOURCES_TO_EXCLUDE[group.version]
            if version_specific_resources
              version_specific_resources.include?(group.resource)
            else
              SpecialCases::RESOURCES_TO_EXCLUDE.include?(group.resource)
            end
          end
            .select { |group| ['au_core_patient', 'au_core_practitioner', 'au_core_organization', 'au_core_practitionerrole'].include? group.name }
            .select { |group| group.searches.present? }
            .each do |group|
              group.searches.each do |search|
                next unless search[:names].include? 'identifier'
                identifier_arr =
                  case group.name
                  when 'au_core_patient'
                    SpecialCases::PATIENT_IDENTIFIERS
                  when 'au_core_practitioner'
                    SpecialCases::PRACTITIONER_IDENTIFIERS
                  when 'au_core_practitionerrole'
                    SpecialCases::PRACTITIONER_ROLE_IDENTIFIERS
                  when 'au_core_organization'
                    SpecialCases::ORGANIZATION_IDENTIFIERS
                  end
                identifier_arr.each do |special_identifier|
                  new(group, search, base_output_dir, special_identifier, ig_metadata).generate
                end
              end
          end
        end
      end

      attr_accessor :group_metadata, :search_metadata, :base_output_dir, :special_identifier, :ig_metadata

      self.template_type = TEMPLATE_TYPES[:SPECIAL_IDENTIFIER_SEARCH]

      def initialize(group_metadata, search_metadata, base_output_dir, special_identifier, ig_metadata)
        super(group_metadata, search_metadata, base_output_dir, ig_metadata)
        self.special_identifier = special_identifier
      end

      def optional?
        true
      end

      def search_properties
        {}.tap do |properties|
          properties[:resource_type] = "'#{resource_type}'"
          properties[:search_param_names] = search_param_names_array
          properties[:token_search_params] = token_search_params_string if token_search_params.present?
          properties[:target_identifier] = special_identifier
        end
      end

      def title
        "Server returns valid results for #{resource_type} search by identifier (#{special_identifier[:display]})"
      end

      def description
        <<~DESCRIPTION.gsub(/\n{3,}/, "\n\n")
          A server SHOULD support searching by
          #{search_param_name_string} (#{special_identifier[:display]}) on the #{resource_type} resource. This test
          will pass if resources are returned and match the search criteria. If
          none are returned, the test is skipped.

          [AU Core Server CapabilityStatement](http://hl7.org.au/fhir/core/#{url_version}/CapabilityStatement-au-core-server.html)
        DESCRIPTION
      end
    end
  end
end
