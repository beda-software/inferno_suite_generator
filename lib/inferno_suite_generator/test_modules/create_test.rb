# frozen_string_literal: true

module InfernoSuiteGenerator
  # Module handles sending FHIR resource instances
  # to a server via the create operation and validating the response. It supports:
  #
  # - Converting input data into FHIR resource instances
  # - Sending create requests to FHIR servers
  # - Validating response status codes and resource types
  # - Verifying server-assigned resource IDs
  module CreateTest
    EXPECTED_CREATE_STATUS = 201

    def perform_create_test
      fhir_create(parse_fhir_resource(resource_payload_for_input))
      assert_create_success
      ensure_id_present(resource_type)
      register_teardown_candidate
    end

    private

    def resource_payload_for_input
      payload = input_data
      skip skip_message(resource_type) if payload.to_s.strip.empty?
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
      return unless resource

      info "Registering #{resource.resourceType} with #{resource.id} for teardown"
      teardown_candidates << resource
    end

    def register_resource_id
      return unless resource

      info "Registering #{resource.id} with #{resource.resourceType} for resource ids"
      demo_resources[resource_type] ||= []
      demo_resources[resource_type] << resource.id
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

    def teardown_candidates
      scratch[:teardown_candidates] ||= []
    end

    def demo_resources
      scratch[:resource_ids] ||= @demodata.resource_ids
    end
  end
end
