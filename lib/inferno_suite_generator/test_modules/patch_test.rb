# frozen_string_literal: true

module InfernoSuiteGenerator
  # Module handles sending FHIR resource instances
  # to a server via the patch operation and validating the response. It supports:
  #
  # - Retrieving existing FHIR resource instances for patching
  # - Sending patch requests to FHIR servers
  # - Validating response status codes (200, 204)
  # - Handling patch operation success scenarios
  module PatchTest
    SUCCESS = 200
    SUCCESS_NO_CONTENT = 204

    def perform_patch_test
      patch_data = resource_payload_for_input
      # fhir_patch(patch_data[:resource_type], patch_data[:id], patch_data[:resource])
      fhir_operation(
        "#{patch_data[:resource_type]}/#{patch_data[:id]}",
        body: patch_data[:resource],
        operation_method: :patch
      )

      assert_patch_success
    end

    private

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
