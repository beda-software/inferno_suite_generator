# frozen_string_literal: true

require_relative "test_helper"

class SmokeTest < Minitest::Test
  def test_version_exists
    refute_nil InfernoSuiteGenerator::VERSION
  end
end
