# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.3.6"

gemspec

gem "inferno_core", "~> 1.0.6"
gem "minitest", "~> 5.25"
gem "rake", "~> 13.3"

group :test do
  gem "simplecov", require: false
end

group :development do
  gem "fasterer", "~> 0.11.0"
  gem "reek", "~> 6.1.0"
  gem "rubocop", "~> 1.59.0"
  gem "rubocop-erb", require: false
  gem "rubocop-md", require: false
  gem "rubocop-packaging", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rake", require: false
  gem "steep", "~> 1.10"
end
