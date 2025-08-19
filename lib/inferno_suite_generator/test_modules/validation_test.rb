# frozen_string_literal: true

require_relative "../utils/assert_helpers"

module InfernoSuiteGenerator
  # Module for validating FHIR resources against profiles and checking for data absent reason codes/extensions.
  module ValidationTest
    include AssertHelpers

    DAR_CODE_SYSTEM_URL = "http://terminology.hl7.org/CodeSystem/data-absent-reason"
    DAR_EXTENSION_URL = "http://hl7.org/fhir/StructureDefinition/data-absent-reason"

    def perform_validation_test(resources,
                                profile_url,
                                profile_version,
                                validation_behavior: :skip_if_empty)
      validate_resource_conditions(resources, profile_url, validation_behavior == :skip_if_empty)
      process_resources(resources, profile_url, profile_version)
    end

    private

    def validate_resource_conditions(resources, profile_url, skip_if_empty)
      resources_blank = resources.blank?
      conditional_skip_with_msg skip_if_empty && resources_blank,
                                "No #{resource_type} resources conforming to the #{profile_url} profile were returned"

      omit_if resources_blank,
              "No #{resource_type} resources provided so the #{profile_url} profile does not apply"
    end

    def process_resources(resources, profile_url, profile_version)
      profile_with_version = "#{profile_url}|#{profile_version}"
      filtered_resources = resources.select { |resource| resource.meta&.profile&.include?(profile_url) }

      filtered_resources.each do |resource|
        resource_is_valid?(resource:, profile_url: profile_with_version)
        check_for_dar(resource)
      end

      errors_found = messages.any? { |message| message[:type] == "error" }

      skip_if invalid_state?(filtered_resources, errors_found),
              "There is no resources with the profile #{profile_with_version}"
      assert !errors_found, "Resource does not conform to the profile #{profile_with_version}"
    end

    def invalid_state?(filtered_resources, errors_found)
      !errors_found && filtered_resources.blank?
    end

    def check_for_dar(resource)
      unless scratch[:dar_code_found]
        resource.each_element do |element, _meta, _path|
          next unless element.is_a?(FHIR::Coding)

          check_for_dar_code(element)
        end
      end

      return if scratch[:dar_extension_found]

      check_for_dar_extension(resource)
    end

    def check_for_dar_code(coding)
      return unless coding.code == "unknown" && coding.system == DAR_CODE_SYSTEM_URL

      scratch[:dar_code_found] = true
      output dar_code_found: "true"
    end

    def check_for_dar_extension(resource)
      return unless resource.source_contents&.include? DAR_EXTENSION_URL

      scratch[:dar_extension_found] = true
      output dar_extension_found: "true"
    end
  end
end
