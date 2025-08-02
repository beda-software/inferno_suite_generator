# frozen_string_literal: true

require "json"

module InfernoSuiteGenerator
  class Generator
    # Manages configuration for the InfernoSuiteGenerator
    #
    # This class is responsible for loading, validating, and providing access to
    # configuration settings used throughout the test suite generation process.
    class GeneratorConfigKeeper
      attr_reader :config, :version, :config_file_path

      def initialize(config_file_path)
        @config_file_path = config_file_path
        @cache = {}
        load_config
        validate_config
      end

      def reload
        @cache = {}
        load_config
        validate_config
        @config
      end

      def get(path, default = nil)
        @config.dig(*path.split(".")) || default
      end

      def ig_link
        get("ig.link")
      end

      def ig_name
        get("ig.name")
      end

      def cs_profile_url
        get("ig.cs_profile_url")
      end

      def cs_version_specific_url
        get("ig.cs_version_specific_url")
      end

      def id
        get("ig.id")
      end

      def title
        get("suite.title")
      end

      def suite_module_name
        "#{module_name_prefix}TestKit"
      end

      def module_directory
        "#{test_id_prefix}_test_kit"
      end

      def tx_server_url
        get("configs.generators.all.tx_server_url")
      end

      def default_fhir_server
        get("configs.generators.all.default_fhir_server")
      end

      def links
        get("suite.links", [])
      end

      def module_name_prefix
        title.gsub(" ", "")
      end

      def test_id_prefix
        title&.downcase.gsub(" ", "_")
      end

      def paths
        get("suite.paths", {})
      end

      def result_folder
        "./lib/#{module_directory}/generated/"
      end

      def related_result_folder
        "/lib/#{module_directory}/generated/"
      end

      def ig_deps_path
        "lib/#{module_directory}/igs/"
      end

      def package_archive_path
        get("ig.package_archive_path", nil)
      end

      def main_file_path
        "lib/#{module_directory}.rb"
      end

      def extra_json_paths
        get("suite.extra_json_paths", [])
      end

      def multiple_and_expectations
        get("configs.extractors.search.multiple_and_expectation", {})
      end

      def multiple_or_expectations
        get("configs.extractors.search.multiple_or_expectation", {})
      end

      def skip_profiles
        get("configs.generators.all.skip_profiles.profiles", [])
      end

      def skip_profile?(profile_url)
        profiles = get("configs.profiles", {})
        profiles.key?(profile_url) ? profiles[profile_url]["skip"] || false : false
      end

      def search_params_to_ignore
        get("configs.generic.search_params_to_ignore", [])
      end

      def search_params_expectation
        get("configs.generic.expectation", [])
      end

      def special_cases
        get("configs.SPECIAL_CASES", {})
      end

      def resources_to_exclude
        get("configs.generators.all.skip_resources.resources", [])
      end

      def profiles_configs
        get("configs.profiles", {})
      end

      def resources_configs
        get("configs.resources", {})
      end

      def skip_profile?(profile_url)
        profiles_configs.key?(profile_url) ? profiles_configs[profile_url]["skip"] || false : false
      end

      def exclude_resource?(resource_type)
        resources_configs.key?(resource_type) ? resources_configs[resource_type]["skip"] || false : false
      end

      def resolve_profile_resource_value(profile_path, resource_path, default_value)
        profile_comparators = get(profile_path, default_value)
        profile_result = constants[profile_comparators] || profile_comparators
        return profile_result if profile_result.any?

        resource_comparators = get(resource_path, default_value)
        constants[resource_comparators] || resource_comparators
      end

      def get_comparators(profile_url, resource_type, param_id)
        resolve_profile_resource_value(
          "configs.profiles.#{profile_url}.search_param.#{param_id}.comparators",
        "configs.resources.#{resource_type}.search_param.#{param_id}.comparators", [])
      end

      def specific_identifiers
        get("configs.extractors.search.identifiers", {})
      end

      def search_params_for_include_by_resource
        get("configs.extractors.search.include_searches_by_resource", {})
      end

      def multiple_or_and_search_by_target_resource
        get("configs.extractors.search.multiple_or_and_search_by_target_resource", {})
      end

      def profiles_to_exclude
        get("configs.extractors.search.profiles_to_exclude", [])
      end

      def search_expectation_overrides
        get("configs.extractors.search.expectation_overrides", {})
      end

      def fixed_search_values(profile_url, resource_type, param_id)
        resolve_profile_resource_value(
          "configs.profiles.#{profile_url}.search_param.#{param_id}.default_values",
          "configs.resources.#{resource_type}.search_param.#{param_id}.default_values", [])
      end

      def read_test_ids_inputs
        get("configs.generators.read.test_ids_inputs", {})
      end

      def name_first_profile?(profile_url)
        name_first_profiles.include?(profile_url)
      end

      def medication_inclusion_resources
        get("configs.extractors.search.test_medication_inclusion.resources", [])
      end

      def special_includes_cases
        get("configs.extractors.search.include_searches.cases", {})
      end

      def special_search_methods
        get("configs.generators.search.method_to_search.methods", [])
      end

      def first_search_params(profile_url, resource)
        profile_config = get("configs.generators.search.first_search_parameter_by.profile", {})
        resource_config = get("configs.generators.search.first_search_parameter_by.resource", {})
        default_value = ["patient"]

        if profile_config.key?(profile_url)
          profile_config[profile_url]
        elsif resource_config.key?(resource)
          resource_config[resource]
        else
          default_value
        end
      end

      def outer_groups
        get("suite.outer_groups", [])
      end

      def extractors
        get("configs.extractors", {})
      end

      def extractors_must_support
        get("configs.extractors.must_support", {})
      end

      def extractors_must_support_remove_elements
        get("configs.extractors.must_support.remove_elements", [])
      end

      def configs_generators_search_first_search_params_config
        get("configs.generators.search.first_search_parameter_by", {})
      end

      def constants
        get("constants", {})
      end

      def keys_at(path)
        section = get(path)
        section.is_a?(Hash) ? section.keys : []
      end

      def values_at(path)
        section = get(path)
        section.is_a?(Hash) ? section.values : []
      end

      def env_override(path)
        env_var = "INFERNO_CONFIG_#{path.tr(".", "_").upcase}"
        ENV[env_var]
      end

      private

      def load_config
        raise ArgumentError, "Configuration file not found: #{@config_file_path}" unless File.exist?(@config_file_path)

        begin
          @config = JSON.parse(File.read(@config_file_path))
          @version = get("ig.version", [])
        rescue JSON::ParserError => e
          raise ArgumentError, "Invalid JSON in configuration file: #{e.message}"
        end
      end

      def validate_config
        required_sections = %w[ig suite configs]

        required_sections.each do |section|
          raise ArgumentError, "Missing required configuration section: #{section}" unless @config.key?(section)
        end
      end
    end
  end
end
