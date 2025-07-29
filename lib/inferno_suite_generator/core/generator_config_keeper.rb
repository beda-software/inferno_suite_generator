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
        @config["ig_link"]
      end

      def ig_name
        @config["ig_name"]
      end

      def cs_profile_url
        @config["cs_profile_url"]
      end

      def cs_version_specific_url
        @config["cs_version_specific_url"]
      end

      def id
        @config["id"]
      end

      def title
        @config["title"]
      end

      def suite_module_name
        @config["suite_module_name"]
      end

      def tx_server_url
        @config["tx_server_url"]
      end

      def default_fhir_server
        @config["default_fhir_server"]
      end

      def links
        @config["links"] || []
      end

      def module_name_prefix
        @config["module_name_prefix"]
      end

      def test_id_prefix
        @config["test_id_prefix"]
      end

      def metadata
        @config["metadata"] || {}
      end

      def description
        metadata["description"]
      end

      def last_updated
        metadata["last_updated"]
      end

      def paths
        @config["paths"] || {}
      end

      def result_folder
        paths["result_folder"]
      end

      def related_result_folder
        paths["related_result_folder"]
      end

      def ig_packages_path
        paths["ig_packages"]
      end

      def ig_deps_path
        paths["ig_deps"]
      end

      def main_file_path
        paths["main_file"]
      end

      def ig_output_directory_path
        paths["ig_output_directory"]
      end

      def ig_json_files_path
        paths["ig_json_files"]
      end

      def extra_json_paths
        paths["extra_json_paths"] || []
      end

      def naming_mappings
        configs["NAMING"] || {}
      end

      def multiple_and_expectations
        configs["multipleAndExpectations"] || {}
      end

      def multiple_or_expectations
        configs["multipleOrExpectations"] || {}
      end

      def constant_name_for_profile(profile_url)
        naming_mappings[profile_url]
      end

      def skip_profiles
        configs.dig("SKIP_PROFILES", "profiles") || []
      end

      def skip_profile?(profile_url)
        skip_profiles.include?(profile_url)
      end

      def search_params_to_ignore
        configs["SEARCH_PARAMS_TO_IGNORE"] || []
      end

      def search_params_expectation
        configs["SEARCH_PARAMS_EXPECTATION"] || []
      end

      def special_cases
        configs["SPECIAL_CASES"] || {}
      end

      def resources_to_exclude
        special_cases.dig("RESOURCES_TO_EXCLUDE", "resources") || []
      end

      def version_specific_resources_to_exclude(version = nil)
        return {} if version.nil?

        special_cases["VERSION_SPECIFIC_RESOURCES_TO_EXCLUDE"] || {}
      end

      def specific_identifiers
        special_cases["SPECIFIC_IDENTIFIER"] || {}
      end

      def search_params_for_include_by_resource
        special_cases["SEARCH_PARAMS_FOR_INCLUDE_BY_RESOURCE"] || {}
      end

      def multiple_or_and_search_by_target_resource
        special_cases["MULTIPLE_OR_AND_SEARCH_BY_TARGET_RESOURCE"] || {}
      end

      def profiles_to_exclude
        special_cases["PROFILES_TO_EXCLUDE"] || []
      end

      def fixed_search_values
        configs["FIXED_SEARCH_VALUES"] || {}
      end

      def jurisdiction_filter
        configs["JURISDICTION_FILTER"] || {}
      end

      def jurisdiction_system
        jurisdiction_filter["system"] || "urn:iso:std:iso:3166"
      end

      def jurisdiction_code
        jurisdiction_filter["code"] || "AU"
      end

      def category_first_profiles
        special_cases.dig("ALL_VERSION_CATEGORY_FIRST_PROFILES", "profiles") || []
      end

      def category_first_profile?(profile_url, version = nil)
        category_first_profiles.include?(profile_url) ||
          version_specific_category_first_profiles(version)&.include?(profile_url)
      end

      def patient_first_profiles
        special_cases.dig("ALL_VERSION_PATIENT_FIRST_PROFILES", "profiles") || []
      end

      def patient_first_profile?(profile_url)
        patient_first_profiles.include?(profile_url)
      end

      def id_first_profiles
        special_cases.dig("ALL_VERSION_ID_FIRST_PROFILES", "profiles") || []
      end

      def id_first_profile?(profile_url)
        id_first_profiles.include?(profile_url)
      end

      def name_first_profiles
        special_cases.dig("ALL_VERSION_NAME_FIRST_PROFILES", "profiles") || []
      end

      def read_test_ids_inputs
        special_cases["READ_TEST_IDS_INPUTS"] || {}
      end

      def name_first_profile?(profile_url)
        name_first_profiles.include?(profile_url)
      end

      def version_specific_profiles(version = nil)
        return {} if version.nil?

        special_cases.dig("VERSION_SPECIFIC_PROFILES", "profiles") || {}
      end

      def version_specific_category_first_profiles(version = nil)
        return [] if version.nil?

        []
      end

      def first_search_params(profile_url, resource, version = nil)
        if category_first_profile?(profile_url, version)
          %w[patient category]
        elsif patient_first_profile?(profile_url)
          ["patient"]
        elsif id_first_profile?(profile_url)
          ["_id"]
        elsif name_first_profile?(profile_url)
          ["name"]
        elsif resource == "Observation"
          %w[patient code]
        elsif resource == "MedicationRequest"
          ["patient"]
        elsif resource == "CareTeam"
          %w[patient status]
        else
          ["patient"]
        end
      end

      def outer_groups
        @config["outer_groups"] || []
      end

      private

      def load_config
        @config = JSON.parse(File.read(@config_file_path))
        @version = @config["version"] || []
      end

      def configs
        @config["configs"] || {}
      end
    end
  end
end
