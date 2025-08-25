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

            %w[XML JSON FHIRPathXML FHIRPathJSON].each do |patch_option|
              new(group, base_output_dir, ig_metadata, patch_option, ig_resources).generate
            end
          end
        end

        def patch_interaction(group_metadata)
          group_metadata.interactions.find { |interaction| interaction[:code] == "patch" }
        end
      end

      attr_reader :ig_resources, :config, :patch_option

      self.template_type = TEMPLATE_TYPES[:PATCH]

      def initialize(group_metadata, base_output_dir, ig_metadata, patch_option, ig_resources = nil)
        super(group_metadata, base_output_dir, ig_metadata)
        @patch_option = patch_option
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
          patchset: patchset
        }
      end

      def humanized_patch_option
        current_test_data["humanized_patch_option"] if current_test_data
      end

      def test_id_patch_option
        current_test_data["test_id_patch_option"] if current_test_data
      end

      def patchset
        current_test_data["patchset"] if current_test_data
      end

      def executor
        current_test_data["executor"] if current_test_data
      end

      private
      
      def current_test_data
        return unless patch_entry

        case patch_option
        when "XML"
          {
            'humanized_patch_option' => 'XMLPatch',
            'test_id_patch_option' => 'xml',
            'patchset' => ParametersParameterDecorator.new(patch_entry.resource.parameter.first).patchset_data,
            'executor' => 'perform_xml_patch_test'
          }
        when "JSON"
          {
            'humanized_patch_option' => 'JSONPatch',
            'test_id_patch_option' => 'json',
            'patchset' => ParametersParameterDecorator.new(patch_entry.resource.parameter.first).patchset_data,
            'executor' => 'perform_json_patch_test'
          }
        when "FHIRPathXML"
          {
            'humanized_patch_option' => 'FHIRPath Patch in XML format',
            'test_id_patch_option' => 'fhirpath_xml',
            'patchset' => patch_entry.resource.to_hash,
            'executor' => 'perform_fhirpath_patch_xml_text'
          }
        when "FHIRPathJSON"
          {
            'humanized_patch_option' => 'FHIRPath Patch in JSON format',
            'test_id_patch_option' => 'fhirpath_json',
            'patchset' => patch_entry.resource.to_hash,
            'executor' => 'perform_fhirpath_patch_json_test'
          }
        else
          raise "Unknown patch option: #{patch_option}"
        end
      end

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
