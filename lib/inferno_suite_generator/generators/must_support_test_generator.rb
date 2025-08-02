# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "basic_test_generator"
require_relative "../utils/registry"

module InfernoSuiteGenerator
  class Generator
    class MustSupportTestGenerator < BasicTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          ig_metadata.groups
                     .reject do |group|
                        Registry.get(:config_keeper).exclude_resource?(group.profile_url, group.resource)
                     end
                     .each { |group| new(group, base_output_dir, ig_metadata).generate }
        end
      end

      attr_accessor :group_metadata, :base_output_dir, :ig_metadata

      self.template_type = TEMPLATE_TYPES[:MUST_SUPPORT]

      def initialize(group_metadata, base_output_dir, ig_metadata)
        self.group_metadata = group_metadata
        self.base_output_dir = base_output_dir
        self.ig_metadata = ig_metadata
      end

      def read_interaction
        self.class.read_interaction(group_metadata)
      end

      def resource_collection_string
        "all_scratch_resources"
      end

      def must_support_list_string
        build_must_support_list_string(false)
      end

      def uscdi_list_string
        build_must_support_list_string(true)
      end

      def title
        Registry.get(:config_keeper).title
      end

      def build_must_support_list_string(uscdi_only)
        slice_names = group_metadata.must_supports[:slices]
                                    .select { |slice| slice[:uscdi_only].presence == uscdi_only.presence }
                                    .map { |slice| slice[:slice_id] }

        element_names = group_metadata.must_supports[:elements]
                                      .select { |element| element[:uscdi_only].presence == uscdi_only.presence }
                                      .map { |element| "#{resource_type}.#{element[:path]}" }

        extension_names = group_metadata.must_supports[:extensions]
                                        .select { |extension| extension[:uscdi_only].presence == uscdi_only.presence }
                                        .map { |extension| extension[:id] }

        group_metadata.must_supports[:choices]&.each do |choice|
          next unless choice[:uscdi_only].presence == uscdi_only.presence && choice.key?(:paths)

          choice[:paths].each { |path| element_names.delete("#{resource_type}.#{path}") }
          element_names << choice[:paths].map { |path| "#{resource_type}.#{path}" }.join(" or ")
        end

        (slice_names + element_names + extension_names)
          .uniq
          .sort
          .map { |name| "#{" " * 8}* #{name}" }
          .join("\n")
      end
    end
  end
end
