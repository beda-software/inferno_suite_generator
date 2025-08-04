# frozen_string_literal: true

require_relative "../utils/naming"
require_relative "search_test_generator"
require_relative "../utils/registry"

module InfernoSuiteGenerator
  class Generator
    class SpecialIdentifierSearchTestGenerator < SearchTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          # TODO: This approach is too custom to keep it inside the generator. Should be fixed or removed because the current structure of the config semantically promise specific search for any resource type and search parameter, but it's not true.
          ig_metadata.groups.reject do |group|
            Registry.get(:config_keeper).resources_to_exclude(group.profile_url, group.resource)
          end
            .select { |group| Registry.get(:config_keeper).specific_identifiers(group.profile_url, group.resource, "identifier").any? }
                     .select { |group| group.searches.present? }
                     .each do |group|
            group.searches.each do |search|
              next unless search[:names].include? "identifier"

              identifier_arr = Registry.get(:config_keeper).specific_identifiers(group.profile_url, group.resource, "identifier")
              identifier_arr.each do |special_identifier|
                new(group, search, base_output_dir, special_identifier, ig_metadata).generate
              end
            end
          end
        end
      end

      attr_accessor :group_metadata, :search_metadata, :base_output_dir, :special_identifier, :ig_metadata

      self.template_type = TEMPLATE_TYPES[:SPECIAL_IDENTIFIER_SEARCH]

      def initialize(group_metadata, search_metadata, base_output_dir, special_identifier, ig_metadata)
        super(group_metadata, search_metadata, base_output_dir, ig_metadata)
        self.special_identifier = special_identifier
      end

      def optional?
        true
      end

      def search_properties
        {}.tap do |properties|
          properties[:resource_type] = "'#{resource_type}'"
          properties[:search_param_names] = search_param_names_array
          properties[:token_search_params] = token_search_params_string if token_search_params.present?
          properties[:target_identifier] = special_identifier.transform_keys(&:to_sym)
        end
      end

      def title
        "Server returns valid results for #{resource_type} search by identifier (#{special_identifier["display"]})"
      end

      def description
        <<~DESCRIPTION.gsub(/\n{3,}/, "\n\n")
          A server SHOULD support searching by
          #{search_param_name_string} (#{special_identifier["display"]}) on the #{resource_type} resource. This test
          will pass if resources are returned and match the search criteria. If
          none are returned, the test is skipped.

          #{capability_statement_reference_string}
        DESCRIPTION
      end
    end
  end
end
