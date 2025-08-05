module InfernoSuiteGenerator
  class Generator
    class GeneratorConfigKeeper
      module GeneratorConfigKeeperGenerators
        def resources_to_exclude(profile_url, resource_type)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.skip",
            "configs&.resources&.#{resource_type}&.skip",
            false
          )
        end

        def add_extra_searches?(profile_url, resource_type, search_names)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.extra_searches",
            "configs&.resources&.#{resource_type}&.extra_searches",
            []
          ).select { |search| search["type"] == "search" }.map { |search| search["params"] }.include?(search_names)
        end

        def exclude_resource_old?(resource_type)
          resources_configs.key?(resource_type) ? resources_configs[resource_type]["skip"] || false : false
        end

        def exclude_resource?(profile_url, resource_type)
          profile_path = "configs&.profiles&.#{profile_url}&.skip"
          resource_path = "configs&.resources&.#{resource_type}&.skip"

          resolve_profile_resource_value(profile_path, resource_path, nil)
        end

        def specific_identifiers(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.extra_tests_with",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.extra_tests_with",
            []
          )
        end

        def get_executor(profile_url, resource, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.override_executor&.search&.#{param_id}",
            "configs&.resources&.#{resource}&.override_executor&.search&.#{param_id}",
            "run_search_test"
          )
        end

        def multiple_or_and_search_by_target_resource(profile_url, resource_type, params)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_multiple_or_and_by_target_resource",
            "configs&.resources&.#{resource_type}&.search_multiple_or_and_by_target_resource",
            []
          ) == params
        end

        def first_class_search(profile_url, resource_type, search_params)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.first_class_profile",
            "configs&.resources&.#{resource_type}&.first_class_profile",
            ""
          ) == "search" && search_params == ["_id"]
        end

        def read_test_ids_inputs(profile_url, resource_type)
          if first_class_read(profile_url, resource_type)
            snake_case_resource_type = camel_to_snake(resource_type)

            {
              "input_id" => "#{snake_case_resource_type}_ids",
              "title" => "#{resource_type} IDs",
              "description" => "Comma separated list of #{snake_case_resource_type.tr("_", " ")} IDs that in sum contain all MUST SUPPORT elements",
              "default" => constants["read_ids.#{snake_case_resource_type}"] || ""
            }
          end
        end

        def search_test_ids_inputs(profile_url, resource_type, param_names)
          if first_class_search(profile_url, resource_type, param_names)
            snake_case_resource_type = camel_to_snake(resource_type)

            {
              "input_id" => "#{snake_case_resource_type}_ids",
              "title" => "#{resource_type} IDs",
              "description" => "Comma separated list of #{snake_case_resource_type.tr("_", " ")} IDs that in sum contain all MUST SUPPORT elements",
              "default" => constants["read_ids.#{snake_case_resource_type}"] || ""
            }
          end
        end

        def test_medication_inclusion?(profile_url, resource_type)
          # NOTE: This attribute of the config should be changed for something generic
          profile_path = "configs&.profiles&.#{profile_url}&.search&.test_medication_inclusion"
          resource_path = "configs&.resources&.#{resource_type}&.search&.test_medication_inclusion"

          resolve_profile_resource_value(
            profile_path,
            resource_path,
            nil
          )
        end

        def special_includes_cases(profile_url, resource)
          result = {}
          extra_searches = resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.extra_searches",
            "configs&.resources&.#{resource}&.extra_searches",
            []
          )
          extra_searches.select { |search| search["type"] == "include" }.each do |search|
            include_parameter = "#{resource}:#{search["param"]}"
            result[include_parameter] = {
              "parameter" => include_parameter,
              "target_resource" => search["target_resource"],
              "paths" => search["paths"]
            }
          end

          result
        end
      end
    end
  end
end
