# frozen_string_literal: true

module InfernoSuiteGenerator
  module CreateTest
    EXPECTED_CREATE_STATUS = 201

    def perform_create_test
      resource_payload = resource_payload_for_input
      resource_instance = parse_fhir_resource(resource_payload)

      fhir_create(resource_instance)

      assert_create_success
      ensure_id_present(resource_type)
      register_teardown_candidate
    end

    private

    def resource_payload_for_input
      payload = send(input_data)
      skip skip_message(resource_type) if blank?(payload)
      payload
    end

    def assert_create_success
      assert_response_status(EXPECTED_CREATE_STATUS)
      assert_resource_type(resource_type)
    end

    def ensure_id_present(type)
      assert resource.id.present?, missing_id_message(type)
    end

    def register_teardown_candidate
      scratch[:teardown_candidates] ||= []
      scratch[:teardown_candidates] << resource
    end

    def blank?(value)
      value.nil? || value.to_s.strip.empty?
    end

    def parse_fhir_resource(payload)
      FHIR.from_contents(payload)
    rescue StandardError => e
      skip "Can't create resource from provided data: #{e.message}"
    end

    def skip_message(resource_type)
      "No #{resource_type} resource provided for create test"
    end

    def missing_id_message(resource_type)
      "Expected server to return an id for created #{resource_type}."
    end
  end
end