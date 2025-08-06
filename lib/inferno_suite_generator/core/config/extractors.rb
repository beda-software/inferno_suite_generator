# frozen_string_literal: true

require_relative "constants"
require_relative "utils"

module InfernoSuiteGenerator
  class Generator
    class GeneratorConfigKeeper
      # Provides methods for extracting specific configuration values for test generation
      #
      # This module contains methods that extract and process configuration values
      # related to search parameters, expectations, and other test-specific settings.
      module GeneratorConfigKeeperExtractors
        include GeneratorConfigKeeperConstants
        include GeneratorConfigKeeperUtils

        def multiple_and_expectation(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.multiple_and_expectation",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.multiple_and_expectation"
          )
        end

        def multiple_or_expectation(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.multiple_or_expectation",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.multiple_or_expectation"
          )
        end

        def override_search_expectation(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.expectation_change",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.expectation_change"
          )
        end

        def fixed_search_values(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.default_values",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.default_values", EMPTY_ARRAY
          )
        end

        def skip_metadata_extraction?(profile_url, resource_type)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.skip",
            "configs&.resources&.#{resource_type}&.skip",
            false
          )
        end

        def must_support_remove_elements(profile_url, resource)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.must_support&.remove_elements",
            "configs&.resources&.#{resource}&.must_support&.remove_elements",
            EMPTY_ARRAY
          )
        end

        def get_comparators(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.comparators",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.comparators", EMPTY_ARRAY
          )
        end

        def get_first_class_status(profile_url, resource)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.first_class_profile",
            "configs&.resources&.#{resource}&.first_class_profile",
            false
          )
        end

        def get_forced_initial_search(profile_url, resource)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.forced_initial_search",
            "configs&.resources&.#{resource}&.forced_initial_search",
            EMPTY_ARRAY
          )
        end

        def first_search_params(profile_url, resource)
          is_first_class = get_first_class_status(profile_url, resource)
          forced_initial_search = get_forced_initial_search(profile_url, resource)
          default_value = ["patient"]

          return ["_id"] if is_first_class
          return forced_initial_search if forced_initial_search.any?

          default_value
        end
      end
    end
  end
end
