# frozen_string_literal: true

module InfernoSuiteGenerator
  class Generator
    module Naming
      class << self
        def resources_with_multiple_profiles
          %w[Condition DiagnosticReport Observation]
        end

        def resource_has_multiple_profiles?(resource)
          resources_with_multiple_profiles.include? resource
        end

        def snake_case_for_profile(group_metadata)
          resource = group_metadata.resource
          return resource.underscore unless resource_has_multiple_profiles?(resource)

          config = Registry.get(:config_keeper)
          test_id_prefix = config.test_id_prefix
          group_metadata.name
                        .delete_prefix("#{test_id_prefix}_")
                        .gsub("diagnosticreport", "diagnostic_report")
                        .underscore
        end

        def upper_camel_case_for_profile(group_metadata)
          snake_case_for_profile(group_metadata).camelize
        end
      end
    end
  end
end
