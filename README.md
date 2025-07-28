# InfernoSuiteGenerator

A Ruby gem for automatically generating test suites for FHIR Implementation Guides (IGs) to be used with the Inferno testing framework.

## Description

InfernoSuiteGenerator is a tool that simplifies the creation of test suites for validating FHIR resources against Implementation Guides. It analyzes FHIR Implementation Guide packages and generates Ruby test classes for the Inferno testing framework.

The generator creates various types of tests:
- Read tests
- Search tests (including multiple OR/AND searches, chain searches, special identifier searches)
- Validation tests
- Must Support tests
- Reference resolution tests
- Provenance revinclude search tests
- Include search tests

## Installation

Add this line to your application's Gemfile:

```ruby
gem "inferno_suite_generator"
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install inferno_suite_generator
```

## Usage

1. Create a configuration file (`config.json`) with your Implementation Guide settings:

```json
{
  "id": "your_ig_id",
  "title": "Your IG Title",
  "suite_module_name": "YourIGSuite",
  "module_name_prefix": "YourIG",
  "test_id_prefix": "your_ig",
  "paths": {
    "ig_deps": "path/to/ig/package",
    "main_file": "path/to/inferno/main/file"
  }
}
```

2. Run the generator:

```ruby
require "inferno_suite_generator"

InfernoSuiteGenerator::Generator.generate
```

This will:
- Load the IG package
- Extract metadata
- Generate test files for various FHIR interactions
- Add the generated test suite to your Inferno application

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/beda-software/inferno_suite_generator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/beda-software/inferno_suite_generator/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the InfernoSuiteGenerator project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/beda-software/inferno_suite_generator/blob/main/CODE_OF_CONDUCT.md).
