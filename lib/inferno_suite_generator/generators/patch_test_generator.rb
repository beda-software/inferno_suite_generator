# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "basic_test_generator"
require_relative "../utils/registry"
require_relative "../decorators/parameters_parameter_decorator"
require_relative "../decorators/bundle_entry_decorator"

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
        return unless patch_entry

        {
          resource_type: resource_type,
          id: patch_entry.request.url.split("/").last,
          patchset: ParametersParameterDecorator.new(patch_entry.resource.parameter.first).patchset_data
        }
      end

      private

      def transaction_bundles
        bundles = ig_resources&.get_resources_by_type("Bundle")&.select { |bundle| bundle.type == "transaction" }
        bundles || []
      end

      def bundle_entries
        transaction_bundles&.flat_map { |bundle| bundle.entry || [] } || []
      end

      def patch_entry
        bundle_entries.find do |entry|
          BundleEntryDecorator.new(entry).bundle_entry_patch_parameter?(resource_type)
        end
      end
    end
  end
end
