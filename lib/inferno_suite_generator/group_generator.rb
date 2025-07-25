# frozen_string_literal: true

require_relative 'naming'
require_relative 'special_cases'
require_relative 'basic_test_generator'
require_relative 'helpers'

module InfernoSuiteGenerator
  class Generator
    class GroupGenerator < BasicTestGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          ig_metadata.ordered_groups
                     .compact
                     .reject do |group|
                       version_specific_resources = SpecialCases::VERSION_SPECIFIC_RESOURCES_TO_EXCLUDE[group.version]
                       if version_specific_resources
                         version_specific_resources.include?(group.resource)
                       else
                         SpecialCases::RESOURCES_TO_EXCLUDE.include?(group.resource)
                       end
                     end
                     .each { |group| new(group, base_output_dir, ig_metadata).generate }
        end
      end

      attr_accessor :group_metadata, :base_output_dir, :ig_metadata

      self.template_type = TEMPLATE_TYPES[:GROUP]

      def initialize(group_metadata, base_output_dir, ig_metadata)
        self.group_metadata = group_metadata
        self.base_output_dir = base_output_dir
        self.ig_metadata = ig_metadata
      end

      def base_metadata_file_name
        'metadata.yml'
      end

      def title
        group_metadata.title
      end

      def short_description
        group_metadata.short_description
      end

      def output_file_name
        File.join(base_output_dir, base_output_file_name)
      end

      def metadata_file_name
        File.join(base_output_dir, profile_identifier, base_metadata_file_name)
      end

      def group_id
        "#{ig_metadata.ig_test_id_prefix}_#{group_metadata.reformatted_version}_#{profile_identifier}"
      end

      def search_validation_resource_type
        "#{resource_type} resources"
      end

      def profile_name
        group_metadata.profile_name
      end

      def profile_url
        group_metadata.profile_url
      end

      def optional?
        resource_type == 'QuestionnaireResponse'
      end

      def generate
        add_special_tests
        File.open(output_file_name, 'w') { |f| f.write(output) }
        group_metadata.id = group_id
        group_metadata.file_name = base_output_file_name
        File.open(metadata_file_name, 'w') { |f| f.write(YAML.dump(group_metadata.to_hash)) }
      end

      def add_special_tests
        return if group_metadata.reformatted_version == 'v311'

        case group_metadata.resource
        when 'DocumentReference'
          group_metadata.add_test(
            id: 'au_core_v400_document_reference_custodian_test',
            file_name: '../../custom_groups/v4.0.0/document_reference_custodian_test.rb'
          )
        end
      end

      def test_id_list
        @test_id_list ||= group_metadata.tests.map { |test| test[:id] }
      end

      def test_file_list
        @test_file_list ||=
          group_metadata.tests.map do |test|
            name_without_suffix = test[:file_name].delete_suffix('.rb')
            name_without_suffix.start_with?('..') ? name_without_suffix : "#{profile_identifier}/#{name_without_suffix}"
          end
      end

      def required_searches
        group_metadata.searches.select { |search| search[:expectation] == 'SHALL' }
      end

      def search_param_name_string
        required_searches
          .map { |search| search[:names].join(' + ') }
          .map { |names| "* #{names}" }
          .join("\n")
      end

      def description
        Helpers.get_group_description_text(title, resource_type, profile_name, group_metadata.version, profile_url,
                                           required_searches, search_param_name_string, search_validation_resource_type, resource_type)
      end
    end
  end
end
