# frozen_string_literal: true

require_relative "../core/ig_metadata"
require_relative "group_metadata_extractor"
require_relative "../utils/registry"

module InfernoSuiteGenerator
  class Generator
    class IGMetadataExtractor
      attr_accessor :ig_resources, :metadata, :config_keeper

      def initialize(ig_resources)
        self.ig_resources = ig_resources
        remove_extra_supported_profiles
        self.metadata = IGMetadata.new
        self.config_keeper = Registry.get(:config_keeper)
      end

      def extract
        add_metadata_from_ig
        add_metadata_from_resources
        metadata
      end

      def add_metadata_from_ig
        metadata.ig_version = "v#{config_keeper.version}"
        metadata.ig_id = config_keeper.id
        metadata.ig_title = config_keeper.title
        metadata.ig_module_name_prefix = config_keeper.module_name_prefix
        metadata.ig_test_id_prefix = config_keeper.test_id_prefix
      end

      def resources_in_capability_statement
        ig_resources.capability_statement.rest.first.resource
      end

      def remove_extra_supported_profiles
        ig_resources.capability_statement.rest.first.resource
                    .find { |resource| resource.type == "Observation" }
                    .supportedProfile.delete_if do |profile_url|
          Registry.get(:config_keeper).profiles_to_exclude.include?(profile_url)
        end
      end

      def add_metadata_from_resources
        profile_arr_to_skip = config_keeper.skip_profiles

        supported_profile_groups = resources_in_capability_statement.flat_map do |resource|
          resource.supportedProfile&.map do |supported_profile|
            supported_profile = supported_profile.split("|").first
            next if profile_arr_to_skip.include?(supported_profile)

            GroupMetadataExtractor.new(resource, supported_profile, metadata, ig_resources).group_metadata
          end
        end.compact

        profile_groups = resources_in_capability_statement.flat_map do |resource|
          next unless resource.profile.present?
          next if profile_arr_to_skip.include?(resource.profile)

          GroupMetadataExtractor.new(resource, resource.profile, metadata, ig_resources).group_metadata
        end.compact

        metadata.groups = supported_profile_groups + profile_groups

        metadata.postprocess_groups(ig_resources)
      end
    end
  end
end
