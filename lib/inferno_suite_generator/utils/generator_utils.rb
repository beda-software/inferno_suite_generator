# frozen_string_literal: true

module InfernoSuiteGenerator
  # Provides generic helper methods for generators
  module GeneratorUtils
    def search_test_properties_string
      search_properties
        .map { |key, value| "#{" " * 8}#{key}: #{value}" }
        .join(",\n")
    end
  end
end
