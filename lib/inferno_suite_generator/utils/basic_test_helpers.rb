# frozen_string_literal: true

module InfernoSuiteGenerator
  # The BasicTestHelpers module provides shared helper methods for InfernoSuiteGenerator tests,
  # including default payloads and configurations used across multiple test cases.
  module BasicTestHelpers
    def default_patch_body_list
      {
        FHIRPATHPatchJson: {
          resource_type => []
        },
        JSONPatch: {
          resource_type => []
        }
      }
    end
  end
end
