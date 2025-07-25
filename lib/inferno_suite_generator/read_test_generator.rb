# frozen_string_literal: true

require_relative 'naming'
require_relative 'special_cases'
require_relative 'basic_test_generator'

module InfernoSuiteGenerator
  class Generator
    class ReadTestGenerator < BasicTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          ig_metadata.groups
                     .reject do |group|
                       version_specific_resources = SpecialCases::VERSION_SPECIFIC_RESOURCES_TO_EXCLUDE[group.version]
                       if version_specific_resources
                         version_specific_resources.include?(group.resource)
                       else
                         SpecialCases::RESOURCES_TO_EXCLUDE.include?(group.resource)
                       end
                     end
                     .select { |group| read_interaction(group).present? }
                     .each { |group| new(group, base_output_dir, ig_metadata).generate }
        end

        def read_interaction(group_metadata)
          group_metadata.interactions.find { |interaction| interaction[:code] == 'read' }
        end
      end

      attr_accessor :group_metadata, :base_output_dir, :ig_metadata

      self.template_type = TEMPLATE_TYPES[:READ]

      def initialize(group_metadata, base_output_dir, ig_metadata)
        self.group_metadata = group_metadata
        self.base_output_dir = base_output_dir
        self.ig_metadata = ig_metadata
      end

      def read_interaction
        self.class.read_interaction(group_metadata)
      end

      def resource_collection_string
        if group_metadata.delayed? && resource_type != 'Provenance'
          "scratch.dig(:references, '#{resource_type}')"
        else
          'all_scratch_resources'
        end
      end

      def conformance_expectation
        read_interaction[:expectation]
      end

      def needs_location_id?
        resource_type == 'Location'
      end

      def needs_organization_id?
        resource_type == 'Organization'
      end

      def needs_practitioner_id?
        resource_type == 'Practitioner'
      end

      def needs_practitioner_role_id?
        resource_type == 'PractitionerRole'
      end

      def needs_healthcare_service_id?
        resource_type == 'HealthcareService'
      end
    end
  end
end
