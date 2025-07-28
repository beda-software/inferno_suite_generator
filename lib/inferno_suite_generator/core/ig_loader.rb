# frozen_string_literal: true

require "active_support/all"
require "fhir_models"
require "pathname"
require "rubygems/package"
require "zlib"
require "json"
require_relative "ig_resources"
require_relative "generator_config_keeper"
require_relative "../utils/registry"

module InfernoSuiteGenerator
  class Generator
    class IGLoader
      attr_accessor :ig_deps_path, :config

      def initialize(ig_deps_path)
        self.ig_deps_path = ig_deps_path
        self.config = Registry.get(:config_keeper)
      end

      def ig_resources
        @ig_resources ||= IGResources.new
      end

      def load
        load_ig
      end

      def load_ig
        json_files = Dir.glob(File.join(Dir.pwd, config.ig_deps_path, "*.json"))

        if config.respond_to?(:extra_json_paths) && config.extra_json_paths.is_a?(Array)
          config.extra_json_paths.each do |extra_path|
            full_path = extra_path.start_with?("/") ? extra_path : File.join(Dir.pwd, extra_path)
            json_files << full_path if File.exist?(full_path)
          end
        end

        json_files.each do |file_path|
          file_content = File.read(file_path)
          bundle = FHIR.from_contents(file_content)
          bundle.entry.each do |entry|
            next if entry.resource.resourceType == "CapabilityStatement" && config.cs_profile_url != entry.resource.url

            ig_resources.add(entry.resource)
          end
        end
        ig_resources
      end
    end
  end
end
