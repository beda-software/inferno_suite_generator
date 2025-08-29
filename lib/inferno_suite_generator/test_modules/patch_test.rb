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
      patchset = patch_body_list_by_patch_type_and_resource_type("JSONPatch", resource_type)
      skip skip_message(resource_type) if patchset.nil?

      available_resource_id_list.each do |resource_id|
        fhir_patch(resource_type, resource_id, patchset)
        break unless response[:status] == NOT_FOUND_STATUS

        info "Resource with id #{resource_id} not found. Waiting other ID..."
        next
      end
      assert_patch_success
    end

    def perform_xml_patch_test
      # TODO: TBI
      skip "Not implemented"
    end

    def perform_fhirpath_patch_json_test
      patchsets = patch_body_list_by_patch_type_and_resource_type("FHIRPATHPatchJson", resource_type)
      skip skip_message(resource_type) if patchsets.nil? || patchsets.empty?

      parameters_resource_hash = patchsets.first

      available_resource_id_list.each do |resource_id|
        fhir_fhirpath_patch_json(resource_type, resource_id, parameters_resource_hash)
        break unless response[:status] == NOT_FOUND_STATUS

        info "Resource with id #{resource_id} not found. Waiting other ID..."
        next
      end
      assert_patch_success
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

    def fhir_fhirpath_patch_json(resource_type, id, parameters_resource_hash, client: :default, name: nil, tags: [])
      store_request_and_refresh_token(fhir_client(client), name, tags) do
        tcp_exception_handler do
          headers = fhir_client(client).fhir_headers
          headers["Content-Type"] = CONTENT_TYPE_HEADERS["FHIRPathPatchJSON"]
          headers["Accept"] = CONTENT_TYPE_HEADERS["FHIRPathPatchJSON"]
          path = "#{resource_type}/#{id}"
          body = parameters_resource_hash.to_json

          fhir_client(client).send(:patch, path, body, headers)
        end
      end
    end
  end
end
