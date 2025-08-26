# frozen_string_literal: true

require_relative "../utils/generic"
require_relative "basic_test"

module InfernoSuiteGenerator
  # Module handles sending FHIR resource instances
  # to a server via the patch operation and validating the response. It supports:
  #
  # - Retrieving existing FHIR resource instances for patching
  # - Sending patch requests to FHIR servers
  # - Validating response status codes (200, 204)
  # - Handling patch operation success scenarios
  module PatchTest
    include GenericUtils
    include BasicTest

    SUCCESS = 200
    SUCCESS_NO_CONTENT = 204

    CONTENT_TYPE_HEADERS = {
      "JSONPatch" => "application/json-patch+json",
      "XMLPatch" => "application/xml-patch+xml",
      "FHIRPathPatchJSON" => "application/fhir+json",
      "FHIRPathPatchXML" => "application/fhir+xml"
    }.freeze

    def perform_json_patch_test
      payload = get_payload("JSONPatch")
      fhir_patch(payload[:resource_type], payload[:id], payload[:patchset])
      assert_patch_success
    end

    def perform_xml_patch_test
      # TODO: TBI
      skip "Not implemented"
    end

    def perform_fhirpath_patch_json_test
      # TODO: TBI
      skip "Not implemented"
    end

    def perform_fhirpath_patch_xml_text
      # TODO: TBI
      skip "Not implemented"
    end

    private

    def resource_ids_fn(resource_type)
      "#{camel_to_snake(resource_type)}_ids"
    end

    def resource_ids_exists?(resource_type)
      respond_to?(resource_ids_fn(resource_type))
    end

    def fetch_resource_ids(resource_type)
      send(resource_ids_fn(resource_type))
    end

    def get_payload(patch_type)
      patchset = patch_body_list_by_patch_type_and_resource_type(patch_type, resource_type)
      skip skip_message(resource_type) if patchset.nil?

      payload_resource = teardown_candidates.find { |resource| resource.resourceType == resource_type }
      if payload_resource
        {
          resource_type:,
          id: available_resource_id,
          patchset:
        }
      elsif resource_ids_exists?(resource_type)
        {
          resource_type:,
          id: fetch_resource_ids(resource_type).split(",").first.strip,
          patchset:
        }
      else
        skip "No resources with type #{resource_type} found for PATCH test"
      end
    end

    def resource_payload_for_input
      payload = patch_data
      skip skip_message(resource_type) if payload.empty?
      payload
    end

    def assert_patch_success
      response_status = response[:status]
      assert [SUCCESS, SUCCESS_NO_CONTENT].include?(response_status),
             error_message(response_status)
    end

    def skip_message(resource_type)
      "No #{resource_type} data provided for patch test"
    end

    def error_message(response_status)
      "Response status is #{response_status}. Expected #{SUCCESS} or #{SUCCESS_NO_CONTENT}"
    end
  end
end
