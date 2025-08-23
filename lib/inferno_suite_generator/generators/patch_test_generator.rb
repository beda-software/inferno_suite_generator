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
        entry = patch_entry
        return unless entry

        {
          resource_type: resource_type,
          id: entry.request.url.split("/").last,
          patchset: patchset_data(entry)
        }
      end

      private

      def patch_entry
        bundles = ig_resources&.get_resources_by_type("Bundle")&.select { |bundle| bundle.type == "transaction" }
        entries = bundles&.flat_map { |bundle| bundle.entry || [] } || []
        entries.find do |entry|
          entry.request.local_method == "PATCH" &&
            entry.request.url.split("/").first == resource_type &&
            entry.resource.resourceType == "Parameters"
        end
      end

      def patchset_data(entry)
        parts = entry.resource&.parameter&.first&.part || []
        op = parts.find { |part| part.name == "type" }&.valueCode
        path = parts.find { |part| part.name == "path" }&.valueString
        value_hash = parts.find { |part| part.name == "value" }&.source_hash
        value_key = value_hash&.keys&.find { |key| key != "name" }
        value = value_key ? value_hash[value_key] : nil

        [{
          op: op,
          path: path,
          value: value
        }]
      end
    end
  end
end
