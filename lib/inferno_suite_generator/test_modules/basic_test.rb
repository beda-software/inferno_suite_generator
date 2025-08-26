# frozen_string_literal: true

module InfernoSuiteGenerator
  # Module provides shared utility methods for FHIR test modules.
  # It supports resource management and cleanup operations including:
  #
  # - Registering resources for teardown after test completion
  # - Maintaining a registry of created resource IDs
  # - Managing scratch space for temporary test data
  # - Providing access to demo data configurations
  module BasicTest
    extend Forwardable
    def_delegators "self.class", :demodata

    def resource_payload_for_input
      payload = resource_body_by_resource_type(resource_type).first
      skip skip_message(resource_type) if payload.nil?

      parse_fhir_resource(payload.to_json)
    end

    def available_resource_id
      available_id = demo_resources[resource_type]&.first
      skip "Can't find ID of resource #{resource_type} for UPDATE" if available_id.nil?

      available_id
    end

    def register_teardown_candidate
      return unless resource

      info "Registering #{resource.resourceType} with #{resource.id} for teardown"
      teardown_candidates << resource
    end

    def register_resource_id
      return unless resource

      info "Registering #{resource.id} of #{resource.resourceType} for resource IDs registry"
      demo_resources[resource_type] ||= []
      demo_resources[resource_type] << resource.id
    end

    def register_resource_id_from_bundle(bundle)
      return unless bundle

      bundle.entry&.map do |entry|
        resource = entry&.resource

        info "Registering #{resource.id} of #{resource.resourceType} for resource IDs registry"
        demo_resources[resource_type] ||= []
        demo_resources[resource_type] << resource.id
      end
    end

    def teardown_candidates
      scratch[:teardown_candidates] ||= []
    end

    def demo_resources
      scratch[:resource_ids] ||= demodata.resource_ids
    end

    def resource_body_by_resource_type(resource_type)
      resource_body_list[resource_type] || []
    end

    def resource_body_list
      scratch[:resource_body_list] ||= demodata.resource_body_list
    end

    def patch_body_list
      scratch[:patch_body_list] ||= demodata.patch_body_list
    end

    def patch_body_list_by_patch_type(patch_type)
      patch_body_list[patch_type.to_sym] || {}
    end

    def patch_body_list_by_patch_type_and_resource_type(patch_type, resource_type)
      patch_body_list_by_patch_type(patch_type)[resource_type] || []
    end

    def parse_fhir_resource(payload)
      FHIR.from_contents(payload)
    rescue StandardError => e
      skip "Can't create resource from provided data: #{e.message}"
    end
  end
end
