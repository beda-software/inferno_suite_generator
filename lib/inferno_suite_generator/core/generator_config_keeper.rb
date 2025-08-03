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
        # TODO: Remove
        @config.dig(*path.split(".")) || default
      end

      def get_new(path, default = nil)
        @config.dig(*path.split("&.")) || default
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
        title.delete(" ")
      end

      def test_id_prefix
        title&.downcase&.tr(" ", "_")
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

      def search_params_to_ignore
        get("configs.generic.search_params_to_ignore", [])
      end

      def search_params_expectation
        get("configs.generic.expectation", [])
      end

      def resources_to_exclude(profile_url, resource_type)
        resolve_profile_resource_value(
          "configs&.profiles&.#{profile_url}&.skip",
          "configs&.resources&.#{resource_type}&.skip",
          false
        )
      end

      def resources_configs
        get("configs.resources", {})
      end

      def skip_metadata_extraction?(profile_url, resource_type)
        resolve_profile_resource_value(
          "configs&.profiles&.#{profile_url}&.skip",
          "configs&.resources&.#{resource_type}&.skip",
          false
        )
      end

      def exclude_resource_old?(resource_type)
        resources_configs.key?(resource_type) ? resources_configs[resource_type]["skip"] || false : false
      end

      def exclude_resource?(profile_url, resource_type)
        profile_path = "configs&.profiles&.#{profile_url}&.skip"
        resource_path = "configs&.resources&.#{resource_type}&.skip"
        result = resolve_profile_resource_value(profile_path, resource_path, nil)
        if resource_type == "Medication"
          puts "profile_path: #{profile_path}"
          puts "resource_path: #{resource_path}"
          puts "get: #{get_new(resource_path, false)}"
          puts "result: #{result}"
        end
        result
      end

      def resolve_profile_resource_value(profile_path, resource_path, default_value)
        profile_comparators = get_new(profile_path, default_value)
        profile_result = constants[profile_comparators] || profile_comparators
        if default_value.is_a?(String)
          return profile_result || default_value
        end
        if default_value.is_a?(TrueClass) || default_value.is_a?(FalseClass)
          return profile_result || default_value
        end
        return profile_result if profile_result&.any?

        resource_comparators = get_new(resource_path, default_value)
        constants[resource_comparators] || resource_comparators
      end

      def get_comparators(profile_url, resource_type, param_id)
        resolve_profile_resource_value(
          "configs&.profiles&.#{profile_url}&.search_param&.#{param_id}&.comparators",
          "configs&.resources&.#{resource_type}&.search_param&.#{param_id}&.comparators", []
        )
      end

      def specific_identifiers
        get("configs.extractors.search.identifiers", {})
      end

      def search_params_for_include_by_resource
        get("configs.extractors.search.include_searches_by_resource", {})
      end

      def multiple_or_and_search_by_target_resource(profile_url, resource_type, params)
        resolve_profile_resource_value(
          "configs&.profiles&.#{profile_url}&.search_multiple_or_and_by_target_resource",
          "configs&.resources&.#{resource_type}&.search_multiple_or_and_by_target_resource",
          []
        ) == params
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

      def read_test_ids_inputs
        get("configs.generators.read.test_ids_inputs", {})
      end

      def medication_inclusion_resources
        get("configs.extractors.search.test_medication_inclusion.resources", [])
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

      def must_support_remove_elements(profile_url, resource)
        resolve_profile_resource_value(
          "configs&.profiles&.#{profile_url}&.must_support&.remove_elements",
          "configs&.resources&.#{resource}&.must_support&.remove_elements",
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

      def constants
        get("constants", {})
      end

      def outer_groups
        get("suite.outer_groups", [])
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
