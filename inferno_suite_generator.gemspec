# frozen_string_literal: true

require_relative "lib/inferno_suite_generator/version"

Gem::Specification.new do |spec|
  spec.name = "inferno_suite_generator"
  spec.version = InfernoSuiteGenerator::VERSION
  spec.authors = ["Pavel Rozhkov", "Ilya Beda"]
  spec.email = %w[prozskov@gmail.com pavel.r@beda.software ir4y.ix@gmail.com ilya@beda.software]

  spec.summary = "A Ruby gem for automatically generating test suites for FHIR Implementation Guides"
  spec.description = "InfernoSuiteGenerator is a tool that simplifies the creation of test suites for validating FHIR resources against Implementation Guides. It analyzes FHIR Implementation Guide packages and generates Ruby test classes for the Inferno testing framework."
  spec.homepage = "https://github.com/beda-software/inferno_suite_generator"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/beda-software/inferno_suite_generator"
  spec.metadata["changelog_uri"] = "https://github.com/beda-software/inferno_suite_generator/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "inferno_core", ">= 0.6.1"
  spec.add_dependency "smart_app_launch_test_kit", ">= 0.4.0"
  spec.add_dependency "tls_test_kit", "~> 0.2.0"

  spec.add_development_dependency "factory_bot", "~> 6.1"
  spec.add_development_dependency "minitest", "~> 5.22"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "steep", "~> 1.9"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
