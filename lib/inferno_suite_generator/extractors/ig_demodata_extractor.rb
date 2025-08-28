# frozen_string_literal: true

require_relative "../core/ig_demodata"
require_relative "group_metadata_extractor"
require_relative "../utils/registry"
require_relative "../decorators/bundle_entry_decorator"

module InfernoSuiteGenerator
  class Generator
    # Extracts demonstration data from Implementation Guide (IG) resources.
    #
    # This class processes FHIR resources from an Implementation Guide and extracts
    # relevant demonstration data including resource IDs, resource bodies, and patch
    # operations. The extracted data is organized and filtered to exclude certain
    # resource types and elements that are not needed for demonstration purposes.
    class IGDemodataExtractor
      attr_accessor :ig_resources, :demodata, :config_keeper

      RESOURCE_TYPES_TO_IGNORE = %w[Basic ValueSet StructureDefinition CapabilityStatement SearchParameter
                                    ImplementationGuide CodeSystem Bundle].freeze
      RESOURCE_ELEMENTS_TO_IGNORE = %w[id text].freeze

      def initialize(ig_resources)
        self.ig_resources = ig_resources
        self.demodata = IGDemodata.new
        self.config_keeper = Registry.get(:config_keeper)
      end

      def extract
        add_resource_ids
        add_resource_body_list
        add_patch_body_list
        demodata
      end

      private

      def add_resource_ids
        result = {}
        all_resources = resources_list
        all_resources.each do |resource|
          next if resource.id.nil?

          result[resource.resourceType] ||= []
          result[resource.resourceType] << resource.id
        end

        demodata.resource_ids = result
      end

      def add_resource_body_list
        result = {}
        resources_list.each do |resource|
          result[resource.resourceType] ||= []

          resource_copy = resource.dup
          resource_copy = resource_copy.source_hash
          resource_copy = resource_copy.except(*RESOURCE_ELEMENTS_TO_IGNORE)

          result[resource.resourceType] << resource_copy
        end

        demodata.resource_body_list = result
      end

      def add_patch_body_list
        result = {}

        bundle_patch_entries.each do |entry|
          resource_type = entry.request.url.split("/").first
          result[:FHIRPATHPatchJson] ||= {}
          result[:FHIRPATHPatchJson][resource_type] ||= []
          result[:JSONPatch] ||= {}
          result[:JSONPatch][resource_type] ||= []

          result[:FHIRPATHPatchJson][resource_type] << entry.resource.source_hash
          result[:JSONPatch][resource_type] << ParametersParameterDecorator.new(
            entry.resource.parameter.first
          ).patchset_data
        end

        demodata.patch_body_list = result
      end

      def bundle_patch_entries
        bundles = ig_resources.get_resources_by_type("Bundle")
        entries = bundles.flat_map { |bundle| bundle.entry || [] }
        entries.select do |entry|
          BundleEntryDecorator.new(entry).bundle_entry_patch_data?
        end
      end

      def resources_list
        result = []
        resource_type_keys = ig_resources.available_resources.reject do |resource_type|
          RESOURCE_TYPES_TO_IGNORE.include?(resource_type)
        end

        resource_type_keys.each do |resource_type|
          ig_resources.get_resources_by_type(resource_type).each do |resource|
            result << resource
          end
        end

        result
      end
    end
  end
end
