# frozen_string_literal: true

require_relative "constants"
require_relative "utils"
require_relative "getters"
require_relative "../../utils/generic"

module InfernoSuiteGenerator
  include GenericUtils
  class Generator
    class GeneratorConfigKeeper
      # Provides methods for generating test-specific configuration and inputs
      #
      # This module contains methods that generate configuration values and inputs
      # for various test types, including search tests, read tests, and special cases.
      module GeneratorConfigKeeperGenerators
        include GeneratorConfigKeeperConstants
        include GeneratorConfigKeeperUtils
        include GeneratorConfigKeeperGetters

        def custom_generators
          get_new("configs&.generic&.register_generators", EMPTY_ARRAY)
        end

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
            EMPTY_ARRAY
          ).select { |search| search["type"] == "search" }.map { |search| search["params"] }.include?(search_names)
        end

        def exclude_resource_old?(resource_type)
          resources_configs.key?(resource_type) ? resources_configs[resource_type]["skip"] || false : false
        end

        def exclude_resource?(profile_url, resource_type)
          resolve_profile_resource_value("configs&.profiles&.#{profile_url}&.skip",
                                         "configs&.resources&.#{resource_type}&.skip", nil)
        end

        def specific_identifiers(profile_url, resource_type, param_id)
          resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.extra_tests_with",
            "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.extra_tests_with",
            EMPTY_ARRAY
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
            EMPTY_ARRAY
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
          return unless first_class_read(profile_url, resource_type)

          snake_case_resource_type = camel_to_snake(resource_type)
          resource_display_name = snake_case_resource_type.tr("_", " ")

          {
            "input_id" => "#{snake_case_resource_type}_ids",
            "title" => "#{resource_type} IDs",
            "description" => "Comma separated list of #{resource_display_name} " \
                             "IDs that in sum contain all MUST SUPPORT elements",
            "default" => constants["read_ids.#{snake_case_resource_type}"] || ""
          }
        end

        def search_test_ids_inputs(profile_url, resource_type, param_names)
          return unless first_class_search(profile_url, resource_type, param_names)

          snake_case_resource_type = GenericUtils::camel_to_snake(resource_type)
          resource_display_name = snake_case_resource_type.tr("_", " ")

          {
            "input_id" => "#{snake_case_resource_type}_ids",
            "title" => "#{resource_type} IDs",
            "description" => "Comma separated list of #{resource_display_name} " \
                             "IDs that in sum contain all MUST SUPPORT elements",
            "default" => constants["read_ids.#{snake_case_resource_type}"] || ""
          }
        end

        def test_medication_inclusion?(profile_url, resource_type)
          # NOTE: This attribute of the config should be changed for something generic
          profile_path = "configs&.profiles&.#{profile_url}&.search&.test_medication_inclusion"
          resource_path = "configs&.resources&.#{resource_type}&.search&.test_medication_inclusion"

          resolve_profile_resource_value(
            profile_path,
            resource_path
          )
        end

        def process_include_search(result, resource, search)
          include_parameter = "#{resource}:#{search["param"]}"
          result[include_parameter] = {
            "parameter" => include_parameter,
            "target_resource" => search["target_resource"],
            "paths" => search["paths"]
          }
          result
        end

        def special_includes_cases(profile_url, resource)
          result = EMPTY_HASH.dup
          extra_searches = resolve_profile_resource_value(
            "configs&.profiles&.#{profile_url}&.extra_searches",
            "configs&.resources&.#{resource}&.extra_searches",
            EMPTY_ARRAY
          )

          extra_searches.select { |search| search["type"] == "include" }
                        .each { |search| process_include_search(result, resource, search) }

          result
        end
      end
    end
  end
end
