# frozen_string_literal: true

require_relative "../decorators/parameters_parameter_decorator"

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

    NOT_FOUND_STATUS = 404

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

    def available_resource_id_list
      teardown_ids = teardown_candidates.select { |resource| resource.resourceType == resource_type }.map(&:id)
      available_ids = demo_resources[resource_type][0..9]
      all_available_ids = teardown_ids + available_ids
      skip "Can't find ID of resource #{resource_type} for UPDATE" if all_available_ids.empty?

      all_available_ids
    end

    def register_teardown_candidate
      return unless resource

      info "Registering #{resource.resourceType} with #{resource.id} for teardown"
      existing_teardown_candidates = teardown_candidates.map { |candidate| "#{candidate.resourceType}/#{candidate.id}" }
      return if existing_teardown_candidates.include? "#{resource.resourceType}/#{resource.id}"

      teardown_candidates << resource
    end

    def register_resource_id
      return unless resource

      info "Registering #{resource.id} of #{resource.resourceType} for resource IDs registry"
      demo_resources[resource_type] ||= []
      return if demo_resources[resource_type].include? resource.id

      demo_resources[resource_type] << resource.id
    end

    def register_resource_id_from_bundle(bundle)
      return unless bundle

      bundle.entry&.map do |entry|
        resource = entry&.resource

        info "Registering #{resource.id} of #{resource.resourceType} for resource IDs registry"
        demo_resources[resource_type] ||= []
        return if demo_resources[resource_type].include? resource.id

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
      initial_demodata = extra_bundle.nil? ? demodata.patch_body_list : patch_body_list_from_input
      scratch[:patch_body_list] ||= initial_demodata
    end

    def patch_body_list_from_input
      info "The test suite will use the data from the provided bundle to PATCH resources"
      bundle = parse_fhir_resource(extra_bundle)
      patch_entries = bundle.entry.select do |entry|
        request = entry.request
        return false if request.nil?

        request.local_method == "PATCH"
      end
      get_patch_body_list(patch_entries)
    end

    def get_patch_body_list(bundle_patch_entries)
      result = {}

      bundle_patch_entries.each do |entry|
        resource_type = entry.request.url.split("/").first
        result[:FHIRPATHPatchJson] ||= {}
        result[:FHIRPATHPatchJson][resource_type] ||= []
        result[:JSONPatch] ||= {}
        result[:JSONPatch][resource_type] ||= []

        result[:FHIRPATHPatchJson][resource_type] << entry.resource.source_hash
        result[:JSONPatch][resource_type] << ParametersParameterDecorator.new(
          entry.resource.parameter.first
        ).patchset_data
      end

      result
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
