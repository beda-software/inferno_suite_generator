# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "basic_test_generator"
require_relative "../utils/registry"
require_relative "../utils/generic"
require_relative "../decorators/parameters_parameter_decorator"
require_relative "../decorators/bundle_entry_decorator"

module InfernoSuiteGenerator
  class Generator
    # The PatchTestGenerator class generates test files for patching FHIR resources.
    # It extends BasicTestGenerator and handles the generation of test files specifically
    # for testing PATCH operations against a FHIR server.
    class PatchTestGenerator < BasicTestGenerator
      include GenericUtils

      class << self
        def generate(ig_metadata, base_output_dir, ig_resources = nil)
          ig_metadata.groups.each do |group|
            next if Registry.get(:config_keeper).exclude_resource?(group.profile_url, group.resource)
            next unless patch_interaction(group).present?

            # [XML JSON FHIRPathXML FHIRPathJSON]
            patch_types = ["FHIRPathJSON"]
            patch_types.each do |patch_option|
              new(group, base_output_dir, ig_metadata, patch_option, ig_resources).generate
            end
          end
        end

        def patch_interaction(group_metadata)
          group_metadata.interactions.find { |interaction| interaction[:code] == "patch" }
        end
      end

      attr_reader :ig_resources, :config, :test_type

      self.template_type = TEMPLATE_TYPES[:PATCH]

      def initialize(group_metadata, base_output_dir, ig_metadata, test_type, ig_resources = nil)
        super(group_metadata, base_output_dir, ig_metadata)
        @test_type = test_type
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

        [patchset]
      end

      def humanized_option
        current_test_data["humanized_option"] if current_test_data
      end

      def test_id_option
        current_test_data["test_id_option"] if current_test_data
      end

      def patchset
        current_test_data["patchset"] if current_test_data
      end

      def executor
        current_test_data["executor"] if current_test_data
      end

      def ids_input_data
        return unless needs_ids_input?

        {
          id: data[:id].to_sym,
          title: data[:title],
          description: data[:description],
          default: data[:default]
        }
      end

      private

      def data
        return unless needs_ids_input?

        snake_case_resource_type = camel_to_snake(resource_type)
        description = "Comma separated list of #{snake_case_resource_type.tr("_", " ")}"
        constants = config.constants

        {
          id: :"#{snake_case_resource_type}_ids",
          title: "#{resource_type} IDs",
          description:,
          default: constants["patch_ids.#{snake_case_resource_type}"] || ""
        }
      end

      def needs_ids_input?
        !group_metadata.interactions.find do |interaction|
          interaction[:code] == "create" && interaction[:expectation] == "SHALL"
        end.present?
      end

      def current_test_data
        parameters_resource = patch_entry&.resource&.to_hash
        patchset = patch_entry ? ParametersParameterDecorator.new(patch_entry.resource.parameter.first).patchset_data : nil

        case test_type
        when "XML"
          {
            "humanized_option" => "XMLPatch",
            "test_id_option" => "xml",
            "patchset" => patchset,
            "executor" => "perform_xml_patch_test"
          }
        when "JSON"
          {
            "humanized_option" => "JSONPatch",
            "test_id_option" => "json",
            "patchset" => patchset,
            "executor" => "perform_json_patch_test"
          }
        when "FHIRPathXML"
          {
            "humanized_option" => "FHIRPath Patch in XML format",
            "test_id_option" => "fhirpath_xml",
            "patchset" => parameters_resource,
            "executor" => "perform_fhirpath_patch_xml_text"
          }
        when "FHIRPathJSON"
          {
            "humanized_option" => "FHIRPath Patch in JSON format",
            "test_id_option" => "fhirpath_json",
            "patchset" => parameters_resource,
            "executor" => "perform_fhirpath_patch_json_test"
          }
        else
          raise "Unknown patch option: #{test_type}"
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
