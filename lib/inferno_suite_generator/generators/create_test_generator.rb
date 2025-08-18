# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "basic_test_generator"
require_relative "../utils/registry"

module InfernoSuiteGenerator
  class Generator
    # The CreateTestGenerator class generates test files for creating FHIR resources.
    # It extends BasicTestGenerator and handles the generation of test files specifically
    # for testing CREATE operations against a FHIR server.
    class CreateTestGenerator < BasicTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir, ig_resources = nil)
          ig_metadata.groups.each do |group|
            next if Registry.get(:config_keeper).exclude_resource?(group.profile_url, group.resource)
            next unless create_interaction(group).present?

            new(group, base_output_dir, ig_metadata, ig_resources).generate
          end
        end

        def create_interaction(group_metadata)
          group_metadata.interactions.find { |interaction| interaction[:code] == "create" }
        end
      end

      attr_accessor :group_metadata, :base_output_dir, :ig_metadata, :ig_resources, :config

      self.template_type = TEMPLATE_TYPES[:CREATE]

      def initialize(group_metadata, base_output_dir, ig_metadata, ig_resources = nil)
        super(group_metadata, base_output_dir, ig_metadata)
        self.ig_resources = ig_resources
        self.config = Registry.get(:config_keeper)
      end

      def create_interaction
        self.class.create_interaction(group_metadata)
      end

      def conformance_expectation
        create_interaction[:expectation]
      end

      def create_input_data
        build_input_data(read_input_data)
      end

      private

      def read_input_data
        config.create_test_input_data(group_metadata.name,
                                      group_metadata.profile_name,
                                      ig_resources.get_resources_by_type(group_metadata.resource) || [])
      end

      def build_input_data(data)
        {
          id: data["input_id"].to_sym,
          title: data["title"],
          description: data["description"],
          default: data["default"].length.positive? ? data["default"].first : "",
          optional: create_interaction[:expectation] != "SHALL"
        }
      end
    end
  end
end
