module InfernoSuiteGenerator
  class Generator
    class GeneratorConfigKeeper
      module GeneratorConfigKeeperExtractors
        def multiple_and_expectation(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.multiple_and_expectation",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.multiple_and_expectation",
            nil
          )
        end

        def multiple_or_expectation(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.multiple_or_expectation",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.multiple_or_expectation",
            nil
          )
        end

        def override_search_expectation(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.expectation_change",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.expectation_change",
            nil
          )
        end

        def fixed_search_values(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.default_values",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.default_values", []
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
            []
          )
        end

        def get_comparators(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.comparators",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.comparators", []
          )
        end

        def first_search_params(profile_url, resource)
          is_first_class = resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.first_class_profile",
            "configs&.resources&.#{resource}&.first_class_profile",
            false
          )
          forced_initial_search = resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.forced_initial_search",
            "configs&.resources&.#{resource}&.forced_initial_search",
            []
          )
          default_value = ["patient"]

          if is_first_class
            ["_id"]
          elsif forced_initial_search.any?
            forced_initial_search
          else
            default_value
          end
        end
      end
    end
  end
end
