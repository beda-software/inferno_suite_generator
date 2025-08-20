# frozen_string_literal: true

begin
  require "simplecov"
  SimpleCov.start do
    enable_coverage :branch
    track_files "lib/**/*.rb"
    add_filter "/test/"
    add_filter "/sig/"
  end
rescue LoadError
  warn "[test] simplecov not installed; skipping coverage collection"
end

require "minitest/autorun"

require "inferno_suite_generator/version"
