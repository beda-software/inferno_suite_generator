# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "basic_test_generator"
require_relative "../utils/registry"

module InfernoSuiteGenerator
  class Generator
    # The PatchTestGenerator class generates test files for patching FHIR resources.
    # It extends BasicTestGenerator and handles the generation of test files specifically
    # for testing PATCH operations against a FHIR server.
    class PatchTestGenerator < BasicTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir, ig_resources = nil)
          ig_metadata.groups.each do |group|
            next if Registry.get(:config_keeper).exclude_resource?(group.profile_url, group.resource)
            next unless patch_interaction(group).present?

            new(group, base_output_dir, ig_metadata, ig_resources).generate
          end
        end

        def patch_interaction(group_metadata)
          group_metadata.interactions.find { |interaction| interaction[:code] == "patch" }
        end
      end

      attr_reader :ig_resources, :config

      self.template_type = TEMPLATE_TYPES[:PATCH]

      def initialize(group_metadata, base_output_dir, ig_metadata, ig_resources = nil)
        super(group_metadata, base_output_dir, ig_metadata)
        @ig_resources = ig_resources
        @config = Registry.get(:config_keeper)
      end

      def patch_interaction
        self.class.patch_interaction(group_metadata)
      end

      def conformance_expectation
        patch_interaction[:expectation]
      end

      def create_patch_data
        build_create_patch_data
      end

      private

      def transaction_bundles
        ig_resources&.get_resources_by_type("Bundle")&.select do |bundle|
          bundle.type == "transaction"
        end
      end

      def patch_entries
        entries = transaction_bundles&.flat_map { |bundle| bundle.entry || [] }
        entries.select { |entry| entry.request.local_method == "PATCH" }
      end

      def patch_entry
        patch_entries.find do |entry|
          entry.request.url.split("/").first == resource_type && entry.resource.resourceType == "Parameters"
        end
      end

      def get_parameter_part_by_name(parameter, part_name)
        parameter_part = parameter.first.part

        parameter_part.find { |part| part.name == part_name }
      end

      def get_value_data(parameter)
        value_hash = get_parameter_part_by_name(parameter, "value").source_hash
        value_key = value_hash.keys.find { |key| key != "name" }

        value_hash[value_key]
      end

      def get_patchset_data(current_patch_entry)
        parameter_part = current_patch_entry.resource.parameter

        [{
          op: get_parameter_part_by_name(parameter, "type").valueCode,
          path: get_parameter_part_by_name(parameter, "path").valueString,
          value: get_value_data(parameter_part)
        }]
      end

      def build_create_patch_data
        current_patch_entry = patch_entry
        return unless current_patch_entry

        {
          resource_type:,
          id: current_patch_entry.request.url.split("/").last,
          patchset: get_patchset_data(current_patch_entry)
        }
      end
    end
  end
end
