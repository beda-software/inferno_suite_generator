# frozen_string_literal: true

require "json"

module InfernoSuiteGenerator
  class Generator
    class GeneratorConfigKeeper
      attr_reader :config, :version

      def initialize(config_file_path)
        @config_file_path = config_file_path
        load_config
      end

      def reload
        load_config
      end

      def ig_link
        ig["link"]
      end

      def ig_name
        ig["name"]
      end

      def cs_profile_url
        ig["cs_profile_url"]
      end

      def cs_version_specific_url
        ig["cs_version_specific_url"]
      end

      def id
        ig["id"]
      end

      def title
        suite["title"]
      end

      def suite_module_name
        suite["suite_module_name"]
      end

      def tx_server_url
        configs_generators_all["tx_server_url"]
      end

      def default_fhir_server
        configs_generators_all["default_fhir_server"]
      end

      def links
        suite["links"] || []
      end

      def module_name_prefix
        suite["module_name_prefix"]
      end

      def test_id_prefix
        suite["test_id_prefix"]
      end

      def paths
        suite["paths"] || {}
      end

      def result_folder
        paths["result_folder"]
      end

      def related_result_folder
        paths["related_result_folder"]
      end

      def ig_deps_path
        paths["ig_deps"]
      end

      def main_file_path
        paths["main_file"]
      end

      def extra_json_paths
        paths["extra_json_paths"] || []
      end

      def multiple_and_expectations
        configs_extractors_search["multiple_and_expectation"] || {}
      end

      def multiple_or_expectations
        configs_extractors_search["multiple_or_expectation"] || {}
      end

      def skip_profiles
        configs_generators_all.dig("skip_profiles", "profiles") || []
      end

      def skip_profile?(profile_url)
        skip_profiles.include?(profile_url)
      end

      def search_params_to_ignore
        configs_extractors_search['search_params_to_ignore'] || []
      end

      def search_params_expectation
        configs_extractors_search['expectation'] || []
      end

      def special_cases
        configs["SPECIAL_CASES"] || {}
      end

      def resources_to_exclude
        configs_generators_all.dig("skip_resources", "resources") || []
      end

      def specific_identifiers
        configs_extractors_search["identifiers"] || {}
      end

      def search_params_for_include_by_resource
        configs_extractors_search["include_searches_by_resource"] || {}
      end

      def multiple_or_and_search_by_target_resource
        configs_extractors_search["multiple_or_and_search_by_target_resource"] || {}
      end

      def profiles_to_exclude
        configs_extractors_search["profiles_to_exclude"] || []
      end

      def search_expectation_overrides
        configs_extractors_search["expectation_overrides"] || {}
      end

      def fixed_search_values
        configs_extractors_search['fixed_search_values'] || {}
      end

      def jurisdiction_filter
        configs_extractors_search['jurisdiction_filter'] || {}
      end

      def jurisdiction_system
        jurisdiction_filter["system"] || "urn:iso:std:iso:3166"
      end

      def jurisdiction_code
        jurisdiction_filter["code"] || "AU"
      end

      def read_test_ids_inputs
        configs_generators_read["test_ids_inputs"] || {}
      end

      def name_first_profile?(profile_url)
        name_first_profiles.include?(profile_url)
      end

      def medication_inclusion_resources
        configs_extractors_search['test_medication_inclusion']&.dig("resources") || []
      end

      def special_includes_cases
        configs_extractors_search["include_searches"]&.dig("cases") || {}
      end

      def special_search_methods
        configs_generators_search["method_to_search"]&.dig("methods") || []
      end

      def first_search_params(profile_url, resource)
        profile_url_config = configs_generators_search_first_search_params_config["profile"] || {}
        resource_config = configs_generators_search_first_search_params_config["resource"] || {}
        default_value = ["patient"]

        if profile_url_config.key?(profile_url)
          profile_url_config[profile_url]
        elsif resource_config.key?(resource)
          resource_config[resource]
        else
          default_value
        end
      end

      def outer_groups
        suite["outer_groups"] || []
      end

      def extractors
        configs["extractors"] || {}
      end

      def extractors_must_support
        extractors["must_support"] || {}
      end

      def extractors_must_support_remove_elements
        extractors_must_support["remove_elements"] || []
      end

      def configs_extractors_search_comparators
        configs_extractors_search["comparators"] || {}
      end

      def configs_generators_search_first_search_params_config
        configs_generators_search["first_search_parameter_by"] || {}
      end

      private

      def load_config
        @config = JSON.parse(File.read(@config_file_path))
        @version = @config["ig"]["version"] || []
      end

      def ig
        @config["ig"] || {}
      end

      def suite
        @config["suite"] || {}
      end

      def configs
        @config["configs"] || {}
      end

      def configs_extractors
        configs["extractors"] || {}
      end

      def configs_extractors_search
        configs_extractors["search"] || {}
      end

      def configs_generators
        configs["generators"] || {}
      end

      def configs_generators_search
        configs_generators["search"] || {}
      end

      def configs_generators_read
        configs_generators["read"] || {}
      end

      def configs_generators_all
        configs_generators["all"] || {}
      end
    end
  end
end
