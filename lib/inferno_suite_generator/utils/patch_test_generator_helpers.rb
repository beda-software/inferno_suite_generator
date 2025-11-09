# frozen_string_literal: true

module InfernoSuiteGenerator
  # Provides helper methods for building test data used by the Patch test generator.
  # These helpers return hashes describing different patch execution options and
  # are intended for internal use within the InfernoSuiteGenerator.
  module PatchTestGeneratorHelpers
    private

    def xml_test_data(patchset)
      {
        "humanized_option" => "XMLPatch",
        "test_id_option" => "xml",
        "patchset" => patchset,
        "executor" => "perform_xml_patch_test"
      }
    end

    def json_test_data(patchset)
      {
        "humanized_option" => "JSONPatch",
        "test_id_option" => "json",
        "patchset" => patchset,
        "executor" => "perform_json_patch_test"
      }
    end

    def fhirpath_xml_data(parameters_resource)
      {
        "humanized_option" => "FHIRPath Patch in XML format",
        "test_id_option" => "fhirpath_xml",
        "patchset" => parameters_resource,
        "executor" => "perform_fhirpath_patch_xml_text"
      }
    end

    def fhirpath_json_data(parameters_resource)
      {
        "humanized_option" => "FHIRPath Patch in JSON format",
        "test_id_option" => "fhirpath_json",
        "patchset" => parameters_resource,
        "executor" => "perform_fhirpath_patch_json_test"
      }
    end

    def patchset_with_dec
      patch_entry ? ParametersParameterDecorator.new(patch_entry.resource.parameter.first).patchset_data : nil
    end

    def bundle_entries
      transaction_bundles&.flat_map { |bundle| bundle.entry || [] } || []
    end

    def patch_entry
      bundle_entries.find do |entry|
        BundleEntryDecorator.new(entry).bundle_entry_patch_parameter?(resource_type)
      end
    end

    def parameters_resource
      patch_entry&.resource&.to_hash
    end

    def transaction_bundles
      bundles = ig_resources&.get_resources_by_type("Bundle")&.select { |bundle| bundle.type == "transaction" }
      bundles || []
    end

    def current_test_data
      test_type_mapping = {
        "XML" => xml_test_data(patchset_with_dec),
        "JSON" => json_test_data(patchset_with_dec),
        "FHIRPathXML" => fhirpath_xml_data(parameters_resource),
        "FHIRPathJSON" => fhirpath_json_data(parameters_resource)
      }
      raise "Unknown patch option: #{test_type}" unless test_type_mapping.key?(test_type)

      test_type_mapping[test_type]
    end
  end
end
