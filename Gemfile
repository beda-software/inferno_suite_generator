# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.3.6"

gemspec

gem "inferno_core", ">= 0.6.1"
gem "minitest", "~> 5.22"
gem "rake", "~> 13.0"

group :rubocop do
  gem "rubocop", "~> 1.21"
  gem "rubocop-erb", require: false
  gem "rubocop-md", require: false
  gem "rubocop-packaging", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rake", require: false
end

group :development do
  gem "fasterer", "~> 0.11.0"
  gem "reek", "~> 6.1.0"
  gem "steep", "~> 1.9"
end
