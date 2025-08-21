# frozen_string_literal: true

module InfernoSuiteGenerator
  # Module handles sending FHIR resource instances
  # to a server via the update operation and validating the response. It supports:
  #
  # - Retrieving existing FHIR resource instances for update
  # - Sending update requests to FHIR servers
  # - Validating response status codes (200, 201, 204)
  # - Handling update operation success scenarios
  module UpdateTest
    EXPECTED_UPDATE_STATUS = 200
    EXPECTED_UPDATE_NEW_STATUS = 201
    EXPECTED_UPDATE_STATUS_WITH_NO_CONTENT = 204

    def perform_update_test
      resource_to_update = resource_payload_for_input
      fhir_update(resource_to_update, resource_to_update.id)
      assert_create_success
    end

    private

    def resource_payload_for_input
      payload = teardown_candidates.find { |resource| resource.resourceType == resource_type }
      skip skip_message(resource_type) if payload.to_s.strip.empty?
      payload
    end

    def assert_update_success
      assert_response_status([EXPECTED_UPDATE_NEW_STATUS,
                              EXPECTED_UPDATE_STATUS,
                              EXPECTED_UPDATE_STATUS_WITH_NO_CONTENT])
    end

    def skip_message(resource_type)
      "No #{resource_type} resource provided for update test"
    end

    def teardown_candidates
      scratch[:teardown_candidates] ||= []
    end
  end
end
