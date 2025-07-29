# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "basic_test_generator"
require_relative "../utils/registry"

module InfernoSuiteGenerator
  class Generator
    class SuiteGenerator < BasicTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          new(ig_metadata, base_output_dir).generate
        end
      end

      attr_accessor :ig_metadata, :base_output_dir, :config_keeper

      self.template_type = TEMPLATE_TYPES[:SUITE]

      def initialize(ig_metadata, base_output_dir)
        self.ig_metadata = ig_metadata
        self.base_output_dir = base_output_dir
        self.config_keeper = Registry.get(:config_keeper)
      end

      def version_specific_message_filters
        []
      end

      def base_output_file_name
        "#{ig_metadata.ig_test_id_prefix}_test_suite.rb"
      end

      def tx_server_url
        config_keeper.tx_server_url
      end

      def module_name
        "#{ig_metadata.ig_module_name_prefix}#{ig_metadata.reformatted_version.upcase}"
      end

      def output_file_name
        File.join(base_output_dir, base_output_file_name)
      end

      def suite_id
        "#{ig_metadata.ig_test_id_prefix}_#{ig_metadata.reformatted_version}"
      end

      def fhir_api_group_id
        "#{ig_metadata.ig_test_id_prefix}_#{ig_metadata.reformatted_version}_fhir_api"
      end

      def title
        "#{ig_metadata.ig_title} #{ig_metadata.ig_version}"
      end

      def groups_title
        ig_metadata.ig_title
      end

      def ig_identifier
        version = ig_metadata.ig_version[1..] # Remove leading 'v'
        "#{ig_metadata.ig_id}##{version}"
      end

      def ig_name
        config_keeper.ig_name
      end
      def ig_link
        config_keeper.ig_link
      end

      def links
        config_keeper.links
      end

      def generate
        template_output = output

        links_array = links.map do |link|
          %(        {
          label: '#{link["label"]}',
          url: '#{link["url"]}'
        })
        end.join(",\n")

        links_replacement = "      links [\n#{links_array}\n      ]"
        template_output.gsub!(/      links \[.*?\]/m, links_replacement)

        File.open(output_file_name, "w") { |f| f.write(template_output) }
      end

      def groups
        ig_metadata.ordered_groups.compact
                   .reject do |group|
                     version_specific_resources = config_keeper.version_specific_resources_to_exclude(group.version)[group.version]
                     if version_specific_resources
                       version_specific_resources.include?(group.resource)
                     else
                       config_keeper.resources_to_exclude.include?(group.resource)
                     end
                   end
      end

      def group_id_list
        @group_id_list ||=
          groups.map(&:id)
      end

      def group_file_list
        @group_file_list ||=
          groups.map { |group| group.file_name.delete_suffix(".rb") }
      end

      def capability_statement_file_name
        # "../../custom_groups/#{ig_metadata.ig_version}/capability_statement_group"
        "../../custom_groups/v0.3.0-ballot/capability_statement_group"
      end

      def capability_statement_group_id
        # "au_core_#{ig_metadata.reformatted_version}_capability_statement"
        "au_core_v030_ballot_capability_statement"
      end

      def outer_groups
        config_keeper.outer_groups
      end

      def imports
        outer_groups.map do |outer_import|
          require_string = outer_import["import_type"] == "relative" ? "require_relative" : "require"
          %(#{require_string} '#{outer_import["import_path"]}')
        end
      end

      def prepare_outer_groups(position)
        outer_groups.select do |outer_group|
          outer_group["group_position"] == position
        end.map do |outer_group|
          %(group from: :#{outer_group["group_id"]})
        end
      end

      def outer_groups_before
        prepare_outer_groups("before")
      end

      def outer_groups_after
        prepare_outer_groups("after")
      end
    end
  end
end
