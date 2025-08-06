# frozen_string_literal: true

module InfernoSuiteGenerator
  class Generator
    class GeneratorConfigKeeper
      # Defines constant values used across the configuration system
      module GeneratorConfigKeeperConstants
        # @type var empty_array: Array[untyped]
        empty_array = []
        EMPTY_ARRAY = empty_array.freeze

        # @type var empty_hash: Hash[untyped, untyped]
        empty_hash = {}
        EMPTY_HASH = empty_hash.freeze
      end
    end
  end
end
