# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "basic_test_generator"
require_relative "../utils/registry"

module InfernoSuiteGenerator
  class Generator
    # The UpdateTestGenerator class generates test files for updating FHIR resources.
    # It extends BasicTestGenerator and handles the generation of test files specifically
    # for testing UPDATE operations against a FHIR server.
    class UpdateTestGenerator < BasicTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          ig_metadata.groups.each do |group|
            next if Registry.get(:config_keeper).exclude_resource?(group.profile_url, group.resource)
            next unless update_interaction(group).present?

            new(group, base_output_dir, ig_metadata).generate
          end
        end

        def update_interaction(group_metadata)
          group_metadata.interactions.find { |interaction| interaction[:code] == "update" }
        end
      end

      self.template_type = TEMPLATE_TYPES[:UPDATE]

      def update_interaction
        self.class.update_interaction(group_metadata)
      end

      def conformance_expectation
        update_interaction[:expectation]
      end

      def optional?
        conformance_expectation != "SHALL"
      end
    end
  end
end
