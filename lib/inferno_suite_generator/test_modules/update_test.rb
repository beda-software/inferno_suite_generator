# frozen_string_literal: true

require_relative "basic_test"

module InfernoSuiteGenerator
  # Module handles sending FHIR resource instances
  # to a server via the update operation and validating the response. It supports:
  #
  # - Retrieving existing FHIR resource instances for update
  # - Sending update requests to FHIR servers
  # - Validating response status codes (200, 201, 204)
  # - Handling update operation success scenarios
  module UpdateTest
    include BasicTest

    EXPECTED_UPDATE_STATUS = 200
    EXPECTED_UPDATE_NEW_STATUS = 201
    EXPECTED_UPDATE_STATUS_WITH_NO_CONTENT = 204

    def perform_update_test
      resource_to_update = resource_payload_for_input
      fhir_update(resource_to_update, resource_to_update.id)
      assert_update_success
    end

    private

    def assert_update_success
      response_status = response[:status]
      assert [EXPECTED_UPDATE_NEW_STATUS, EXPECTED_UPDATE_STATUS,
              EXPECTED_UPDATE_STATUS_WITH_NO_CONTENT].include?(response_status),
             error_message(response_status)
    end

    def skip_message(resource_type)
      "No #{resource_type} resource provided for update test"
    end

    def error_message(response_status)
      "Response status is #{response_status}. Expected #{EXPECTED_UPDATE_NEW_STATUS}, #{EXPECTED_UPDATE_STATUS} or
              #{EXPECTED_UPDATE_STATUS_WITH_NO_CONTENT}"
    end
  end
end
