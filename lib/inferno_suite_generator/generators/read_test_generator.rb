# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "basic_test_generator"
require_relative "../utils/registry"

module InfernoSuiteGenerator
  class Generator
    class ReadTestGenerator < BasicTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          ig_metadata.groups
                     .reject do |group|
                        Registry.get(:config_keeper).exclude_resource?(group.profile_url, group.resource)
                     end
                     .select { |group| read_interaction(group).present? }
                     .each { |group| new(group, base_output_dir, ig_metadata).generate }
        end

        def read_interaction(group_metadata)
          group_metadata.interactions.find { |interaction| interaction[:code] == "read" }
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
        if group_metadata.delayed? && resource_type != "Provenance"
          "scratch.dig(:references, '#{resource_type}')"
        else
          "all_scratch_resources"
        end
      end

      def conformance_expectation
        read_interaction[:expectation]
      end

      def ids_input_data
        return unless needs_ids_input?

        data = Registry.get(:config_keeper).read_test_ids_inputs[resource_type]

        {
          id: data["input_id"].to_sym,
          title: data["title"],
          description: data["description"],
          default: data["default"]
        }
      end

      private

      def needs_ids_input?
        Registry.get(:config_keeper).read_test_ids_inputs.include?(resource_type)
      end
    end
  end
end
