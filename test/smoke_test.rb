# frozen_string_literal: true

require_relative "test_helper"

class SmokeTest < Minitest::Test
  def test_version_exists
    refute_nil InfernoSuiteGenerator::VERSION
  end

  def test_true_is_true
    assert true
  end
end
