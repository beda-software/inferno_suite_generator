# frozen_string_literal: true

require_relative "naming"
require_relative "basic_test_generator"
require_relative "registry"

module InfernoSuiteGenerator
  class Generator
    class ReferenceResolutionTestGenerator < BasicTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          ig_metadata.groups
                     .reject do |group|
                       config = Registry.get(:config_keeper)
                       version_specific_resources = config.version_specific_resources_to_exclude(group.version)[group.version]
                       if version_specific_resources
                         version_specific_resources.include?(group.resource)
                       else
                         config.resources_to_exclude.include?(group.resource)
                       end
                     end
                     .each { |group| new(group, base_output_dir, ig_metadata).generate }
        end
      end

      attr_accessor :group_metadata, :base_output_dir, :ig_metadata

      self.template_type = TEMPLATE_TYPES[:REFERENCE_RESOLUTION]

      def initialize(group_metadata, base_output_dir, ig_metadata)
        self.group_metadata = group_metadata
        self.base_output_dir = base_output_dir
        self.ig_metadata = ig_metadata
      end

      def resource_collection_string
        "scratch_resources[:all]"
      end

      def must_support_references
        group_metadata.must_supports[:elements]
                      .select { |element| element[:types]&.include?("Reference") }
      end

      def must_support_reference_list_string
        must_support_references
          .map { |element| "#{" " * 8}* #{resource_type}.#{element[:path]}" }
          .uniq
          .sort
          .join("\n")
      end

      def generate
        return if must_support_references.empty?

        FileUtils.mkdir_p(output_file_directory)
        File.open(output_file_name, "w") { |f| f.write(output) }

        group_metadata.add_test(
          id: test_id,
          file_name: base_output_file_name
        )
      end
    end
  end
end
