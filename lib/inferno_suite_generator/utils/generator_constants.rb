# frozen_string_literal: true

module InfernoSuiteGenerator
  class Generator
    module GeneratorConstants
      TEMPLATE_TYPES = {
        CREATE: "create",
        UPDATE: "update",
        READ: "read",
        MULTIPLE_AND_SEARCH: "multiple_and_search",
        SEARCH: "search",
        CHAIN_SEARCH: "chain_search",
        VALIDATION: "validation",
        INCLUDE: "include",
        SPECIAL_IDENTIFIER_SEARCH: "special_identifier_search",
        SPECIAL_IDENTIFIER_CHAIN_SEARCH: "special_identifier_chain_search",
        MULTIPLE_OR_SEARCH: "multiple_or_search",
        REFERENCE_RESOLUTION: "reference_resolution",
        PROVENANCE_REVINCLUDE_SEARCH: "provenance_revinclude_search",
        MUST_SUPPORT: "must_support",
        SUITE: "suite",
        GROUP: "group"
      }.freeze

      CLASS_NAME_SUFFIXES = {
        TEMPLATE_TYPES[:CREATE] => "CreateTest",
        TEMPLATE_TYPES[:UPDATE] => "UpdateTest",
        TEMPLATE_TYPES[:READ] => "ReadTest",
        TEMPLATE_TYPES[:MULTIPLE_AND_SEARCH] => "MultipleAndSearchTest",
        TEMPLATE_TYPES[:SEARCH] => "SearchTest",
        TEMPLATE_TYPES[:CHAIN_SEARCH] => "ChainSearchTest",
        TEMPLATE_TYPES[:VALIDATION] => "ValidationTest",
        TEMPLATE_TYPES[:MULTIPLE_OR_SEARCH] => "MultipleOrSearchTest",
        TEMPLATE_TYPES[:REFERENCE_RESOLUTION] => "ReferenceResolutionTest",
        TEMPLATE_TYPES[:PROVENANCE_REVINCLUDE_SEARCH] => "SearchTest",
        TEMPLATE_TYPES[:MUST_SUPPORT] => "MustSupportTest"
      }.freeze

      TEST_ID_SUFFIXES = {
        TEMPLATE_TYPES[:CREATE] => "create_test",
        TEMPLATE_TYPES[:UPDATE] => "update_test",
        TEMPLATE_TYPES[:READ] => "read_test",
        TEMPLATE_TYPES[:MULTIPLE_AND_SEARCH] => "multiple_and_search_test",
        TEMPLATE_TYPES[:SEARCH] => "search_test",
        TEMPLATE_TYPES[:CHAIN_SEARCH] => "chain_search_test",
        TEMPLATE_TYPES[:VALIDATION] => "validation_test",
        TEMPLATE_TYPES[:MULTIPLE_OR_SEARCH] => "multiple_or_search_test",
        TEMPLATE_TYPES[:REFERENCE_RESOLUTION] => "reference_resolution_test",
        TEMPLATE_TYPES[:PROVENANCE_REVINCLUDE_SEARCH] => "search_test",
        TEMPLATE_TYPES[:MUST_SUPPORT] => "must_support_test"
      }.freeze

      TEMPLATE_FILES_MAP = {
        TEMPLATE_TYPES[:CREATE] => "create.rb.erb",
        TEMPLATE_TYPES[:UPDATE] => "update.rb.erb",
        TEMPLATE_TYPES[:MULTIPLE_AND_SEARCH] => "multiple_and_search.rb.erb",
        TEMPLATE_TYPES[:SEARCH] => "search.rb.erb",
        TEMPLATE_TYPES[:CHAIN_SEARCH] => "chain_search.rb.erb",
        TEMPLATE_TYPES[:VALIDATION] => "validation.rb.erb",
        TEMPLATE_TYPES[:SUITE] => "suite.rb.erb",
        TEMPLATE_TYPES[:INCLUDE] => "include.rb.erb",
        TEMPLATE_TYPES[:SPECIAL_IDENTIFIER_SEARCH] => "special_identifier_search.rb.erb",
        TEMPLATE_TYPES[:SPECIAL_IDENTIFIER_CHAIN_SEARCH] => "chain_search.rb.erb",
        TEMPLATE_TYPES[:MULTIPLE_OR_SEARCH] => "multiple_or_search.rb.erb",
        TEMPLATE_TYPES[:REFERENCE_RESOLUTION] => "reference_resolution.rb.erb",
        TEMPLATE_TYPES[:READ] => "read.rb.erb",
        TEMPLATE_TYPES[:PROVENANCE_REVINCLUDE_SEARCH] => "provenance_revinclude_search.rb.erb",
        TEMPLATE_TYPES[:GROUP] => "group.rb.erb",
        TEMPLATE_TYPES[:MUST_SUPPORT] => "must_support.rb.erb"
      }.freeze
    end
  end
end
