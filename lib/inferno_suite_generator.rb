# frozen_string_literal: true

require "fhir_models"
require "inferno/ext/fhir_models"

require_relative "inferno_suite_generator/core/ig_loader"
require_relative "inferno_suite_generator/extractors/ig_metadata_extractor"
require_relative "inferno_suite_generator/generators/group_generator"
require_relative "inferno_suite_generator/generators/must_support_test_generator"
require_relative "inferno_suite_generator/generators/provenance_revinclude_search_test_generator"
require_relative "inferno_suite_generator/generators/read_test_generator"
require_relative "inferno_suite_generator/generators/reference_resolution_test_generator"
require_relative "inferno_suite_generator/generators/search_test_generator"
require_relative "inferno_suite_generator/generators/suite_generator"
require_relative "inferno_suite_generator/generators/validation_test_generator"
require_relative "inferno_suite_generator/generators/multiple_or_search_test_generator"
require_relative "inferno_suite_generator/generators/multiple_and_search_test_generator"
require_relative "inferno_suite_generator/generators/chain_search_test_generator"
require_relative "inferno_suite_generator/generators/special_identifier_search_test_generator"
require_relative "inferno_suite_generator/generators/special_identifiers_chain_search_test_generator"
require_relative "inferno_suite_generator/generators/include_search_test_generator"
require_relative "inferno_suite_generator/core/generator_config_keeper"
require_relative "inferno_suite_generator/utils/registry"
require_relative "inferno_suite_generator/utils/helpers"

module InfernoSuiteGenerator
  class Generator
    def self.generate(config_path = nil)
      Registry.register(:config_keeper, GeneratorConfigKeeper.new(config_path))
      config = Registry.get(:config_keeper)
      new(config.ig_deps_path).generate
    end

    attr_accessor :ig_resources, :ig_metadata, :ig_deps_path

    def initialize(ig_deps_path)
      self.ig_deps_path = ig_deps_path
    end

    def generate
      # puts "Generating tests for IG #{File.basename(ig_deps_path)}"
      load_ig_package
      extract_metadata
      generate_search_tests
      generate_read_tests
      generate_provenance_revinclude_search_tests
      generate_include_search_tests
      generate_validation_tests
      generate_must_support_tests
      generate_reference_resolution_tests
      generate_groups
      generate_suites
      use_tests
    end

    def extract_metadata
      self.ig_metadata = IGMetadataExtractor.new(ig_resources).extract

      FileUtils.mkdir_p(base_output_dir)
      File.open(File.join(base_output_dir, "metadata.yml"), "w") do |file|
        file.write(YAML.dump(ig_metadata.to_hash))
      end
    end

    def base_output_dir
      File.join(Registry.get(:config_keeper).result_folder, ig_metadata.ig_version)
    end

    def load_ig_package
      FHIR.logger = Logger.new("/dev/null")
      self.ig_resources = IGLoader.new(ig_deps_path).load
    end

    def generate_reference_resolution_tests
      ReferenceResolutionTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_must_support_tests
      MustSupportTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_validation_tests
      ValidationTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_read_tests
      ReadTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_search_tests
      SearchTestGenerator.generate(ig_metadata, base_output_dir)
      generate_multiple_or_search_tests
      generate_multiple_and_search_tests
      generate_chain_search_tests
      generate_special_identifier_search_tests
      generate_special_identifiers_chain_search_tests
    end

    def generate_include_search_tests
      IncludeSearchTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_provenance_revinclude_search_tests
      ProvenanceRevincludeSearchTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_multiple_or_search_tests
      MultipleOrSearchTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_multiple_and_search_tests
      MultipleAndSearchTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_chain_search_tests
      ChainSearchTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_special_identifier_search_tests
      SpecialIdentifierSearchTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_special_identifiers_chain_search_tests
      SpecialIdentifiersChainSearchTestGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_groups
      GroupGenerator.generate(ig_metadata, base_output_dir)
    end

    def generate_suites
      SuiteGenerator.generate(ig_metadata, base_output_dir)
    end

    def use_tests
      config = Registry.get(:config_keeper)
      main_file = config.main_file_path
      file_path = File.expand_path(main_file, Dir.pwd)
      related_result_folder = Registry.get(:config_keeper).result_folder

      file_content = File.read(file_path)
      string_to_add = "require_relative '#{related_result_folder.split("/opt/inferno/lib/").last}/au_core_test_suite'"

      return if file_content.include? string_to_add

      file_content << "\n#{string_to_add}"
      File.write(file_path, file_content)
    end
  end
end
