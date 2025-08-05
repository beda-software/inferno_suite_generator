# frozen_string_literal: true

require "json"
require_relative "config/getters"
require_relative "config/extractors"
require_relative "config/generators"

module InfernoSuiteGenerator
  class Generator
    # Manages configuration for the InfernoSuiteGenerator
    #
    # This class is responsible for loading, validating, and providing access to
    # configuration settings used throughout the test suite generation process.
    class GeneratorConfigKeeper
      include GeneratorConfigKeeperGetters
      include GeneratorConfigKeeperExtractors
      include GeneratorConfigKeeperGenerators

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

      def suite_module_name
        "#{module_name_prefix}TestKit"
      end

      def module_directory
        "#{test_id_prefix}_test_kit"
      end

      def module_name_prefix
        title.delete(" ")
      end

      def test_id_prefix
        title&.downcase&.tr(" ", "_")
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

      def main_file_path
        "lib/#{module_directory}.rb"
      end

      def simple_type?(value)
        value.is_a?(String) || value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end

      def collection_with_elements?(value)
        value.respond_to?(:any?) && value.any?
      end

      def resolve_from_constants(value)
        constants[value] || value
      end

      # Resolve configuration value from profile or resource path with fallback to default
      def resolve_profile_resource_value(profile_path, resource_path, default_value = nil)
        profile_value = get_new(profile_path, default_value)
        resolved_profile_value = resolve_from_constants(profile_value)

        return resolved_profile_value || default_value if simple_type?(default_value)
        return resolved_profile_value if collection_with_elements?(resolved_profile_value)

        resource_value = get_new(resource_path, default_value)
        resolve_from_constants(resource_value)
      end

      def camel_to_snake(str)
        str.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase
      end

      def first_class_read(profile_url, resource_type)
        resolve_profile_resource_value(
          "configs&.profiles&.#{profile_url}&.first_class_profile",
          "configs&.resources&.#{resource_type}&.first_class_profile",
          ""
        ) == "read"
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
