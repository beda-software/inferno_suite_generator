# InfernoSuiteGenerator

A Ruby gem for automatically generating test suites for FHIR Implementation Guides (IGs) to be used with the Inferno testing framework.

## Description

InfernoSuiteGenerator is a tool that simplifies the creation of test suites for validating FHIR resources against Implementation Guides. It analyzes FHIR Implementation Guide packages and generates Ruby test classes for the Inferno testing framework.

The generator creates various types of tests:
- Read tests (retrieving resources by ID)
- Search tests (including multiple OR/AND searches, chain searches, special identifier searches)
- Validation tests (validating resources against profiles)
- Must Support tests (verifying required elements are present)
- Reference resolution tests (ensuring references can be resolved)
- Provenance revinclude search tests (searching for Provenance resources)
- Include search tests (testing _include parameters)

## Project Structure

The project is organized into several key components:

- **Main Generator** (`lib/inferno_suite_generator.rb`): Orchestrates the entire generation process
- **Metadata Extractors** (`lib/inferno_suite_generator/extractors/`): Extract information from FHIR IGs
- **Test Generators** (`lib/inferno_suite_generator/generators/`): Create specific types of tests
- **Configuration System** (`lib/inferno_suite_generator/core/generator_config_keeper.rb`): Manages settings and customizations
- **Template System** (`lib/inferno_suite_generator/templates/`): Uses ERB templates to generate Ruby code
- **Test Modules** (`lib/inferno_suite_generator/test_modules/`): Provide common functionality for generated tests
- **Utilities** (`lib/inferno_suite_generator/utils/`): Helper functions and constants

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

### Basic Usage

1. Create a configuration file (`config.json`) with your Implementation Guide settings (see Configuration section below)
2. Run the generator:

```ruby
require "inferno_suite_generator"

InfernoSuiteGenerator::Generator.generate("path/to/config.json")
```

This will:
- Load the IG package
- Extract metadata about resources and profiles
- Generate test files for various FHIR interactions
- Organize tests into groups and suites
- Add the generated test suite to your Inferno application

### Generation Process

The generator follows these steps:

1. **Load IG Package**: Loads the FHIR Implementation Guide package
2. **Extract Metadata**: Extracts information about resources, profiles, and search parameters
3. **Generate Tests**: Creates various types of tests based on the metadata
   - Search tests (including specialized search types)
   - Read tests
   - Provenance revinclude search tests
   - Include search tests
   - Validation tests
   - Must Support tests
   - Reference resolution tests
4. **Generate Groups**: Organizes tests into groups by resource type
5. **Generate Suites**: Creates a test suite that includes all the groups
6. **Integrate with Inferno**: Adds the generated suite to the main Inferno application

## Configuration

The configuration file (`config.json`) controls how the generator works. Here's an example configuration with explanations:

```json
{
  "ig": {
    "id": "your_ig_id",
    "version": "1.0.0",
    "name": "Your IG Name",
    "link": "https://example.com/your-ig",
    "cs_profile_url": "http://example.com/fhir/CapabilityStatement/your-ig-server",
    "cs_version_specific_url": "https://example.com/your-ig/1.0.0/CapabilityStatement-your-ig-server.html"
  },
  "suite": {
    "title": "Your IG Title",
    "suite_module_name": "YourIGTestKit",
    "module_name_prefix": "YourIG",
    "test_id_prefix": "your_ig",
    "paths": {
      "ig_deps": "path/to/ig/package",
      "result_folder": "./lib/your_ig_test_kit/generated/",
      "related_result_folder": "/lib/your_ig_test_kit/generated/",
      "main_file": "lib/your_ig_test_kit.rb",
      "extra_json_paths": ["extra-config.json"]
    },
    "links": [
      {
        "label": "Report Issue",
        "url": "https://github.com/your-org/your-repo/issues"
      },
      {
        "label": "Your IG",
        "url": "https://example.com/your-ig"
      }
    ]
  },
  "configs": {
    "generators": {
      "all": {
        "default_fhir_server": "https://example.com/fhir",
        "tx_server_url": "https://tx.fhir.org/r4",
        "skip_resources": {
          "resources": ["Medication", "DiagnosticReport"]
        },
        "skip_profiles": {
          "profiles": [
            "http://example.com/fhir/StructureDefinition/your-profile"
          ]
        }
      },
      "read": {
        "test_ids_inputs": {
          "Patient": {
            "input_id": "patient_ids",
            "title": "Patient IDs",
            "description": "Comma separated list of patient IDs that in sum contain all MUST SUPPORT elements",
            "default": "patient1, patient2"
          }
        }
      },
      "search": {
        "first_search_parameter_by": {
          "profile": {
            "http://example.com/fhir/StructureDefinition/your-profile": ["patient", "category"]
          },
          "resource": {
            "Observation": ["patient", "code"]
          }
        }
      }
    },
    "extractors": {
      "search": {
        "fixed_search_values": {
          "values": {
            "date": ["ge2020-01-01", "le2023-12-31"]
          }
        },
        "params_to_ignore": ["count", "_sort"],
        "expectation": ["SHALL", "SHOULD", "MAY"]
      },
      "must_support": {
        "remove_elements": [
          {
            "profiles": ["http://example.com/fhir/StructureDefinition/your-profile"],
            "element_key": "path",
            "condition": "equal",
            "value": "method"
          }
        ]
      }
    }
  }
}
```

### Configuration Options

#### IG Section
- `id`: The ID of the Implementation Guide
- `version`: The version of the Implementation Guide
- `name`: The name of the Implementation Guide
- `link`: The URL to the Implementation Guide
- `cs_profile_url`: The URL to the CapabilityStatement profile
- `cs_version_specific_url`: The URL to the version-specific CapabilityStatement

#### Suite Section
- `title`: The title of the test suite
- `suite_module_name`: The name of the Ruby module for the test suite
- `module_name_prefix`: The prefix for module names
- `test_id_prefix`: The prefix for test IDs
- `paths`: Paths for various files and directories
  - `ig_deps`: Path to the IG package
  - `result_folder`: Path where generated files will be stored
  - `related_result_folder`: Related path for imports
  - `main_file`: Path to the main file of the Inferno application
  - `extra_json_paths`: Additional JSON configuration files
- `links`: Links to be included in the test suite
- `outer_groups`: Additional groups to include in the test suite

#### Configs Section
- `generators`: Configuration for test generators
  - `all`: Configuration for all generators
    - `default_fhir_server`: Default FHIR server URL
    - `tx_server_url`: Terminology server URL
    - `skip_resources`: Resources to skip during generation
    - `skip_profiles`: Profiles to skip during generation
  - `read`: Configuration for read tests
  - `search`: Configuration for search tests
- `extractors`: Configuration for metadata extractors
  - `search`: Configuration for search metadata
  - `must_support`: Configuration for must support metadata

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Project Structure

The project follows a clear organization pattern:

1. **Main Module**: `InfernoSuiteGenerator` module contains all classes
2. **Generator Class**: Main orchestrator that coordinates the entire process
3. **Test Generators**: Inherit from `BasicTestGenerator` and implement specific test types
4. **Metadata Extractors**: Extract and process metadata from FHIR IGs
5. **Configuration**: Uses Registry pattern for global configuration

### Docker

The InfernoSuiteGenerator is available as a Docker image from GitHub Container Registry. This allows you to run the generator without setting up a Ruby environment.

#### Using the Docker Image

Pull the latest image:

```bash
docker pull ghcr.io/beda-software/inferno_suite_generator:latest
```

Run the generator with your configuration file:

```bash
docker run -v $(pwd):/data ghcr.io/beda-software/inferno_suite_generator:latest /data/config.json
```

This mounts your current directory to `/data` in the container and runs the generator with your configuration file.

#### Building the Docker Image Locally

You can also build the Docker image locally:

```bash
docker build -t inferno_suite_generator .
```

And run it:

```bash
docker run -v $(pwd):/data inferno_suite_generator /data/config.json
```

### CI/CD

The project uses GitHub Actions for continuous integration and delivery:

1. **Code Style Checking**: RuboCop runs on all pull requests and pushes to the main branch to ensure code quality.
2. **Docker Image Building**: When changes are pushed to the main branch, a Docker image is automatically built and pushed to GitHub Container Registry.
3. **Manual Build and Push**: A separate workflow is available for manually triggering the build and push process without running RuboCop checks.

The CI/CD pipeline ensures that:
- Code follows the style guidelines
- The Docker image is always up-to-date with the latest changes
- The Docker image is available for easy use without local setup

#### Manual Build and Push

In some cases, you may need to build and push a Docker image without running RuboCop checks. For this purpose, a manual workflow is available:

1. Go to the GitHub repository
2. Navigate to the "Actions" tab
3. Select the "Manual Build and Push" workflow
4. Click "Run workflow"
5. Optionally, provide a reason for the manual build
6. Click "Run workflow" to start the build and push process

This is useful in situations where you need to quickly deploy a new image without addressing code style issues.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/beda-software/inferno_suite_generator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/beda-software/inferno_suite_generator/blob/main/CODE_OF_CONDUCT.md).

### Best Practices for Modifying the Codebase

1. **Respect the patterns**: Follow existing patterns for naming, organization, and inheritance
2. **Maintain separation of concerns**: Keep generators focused on single responsibilities
3. **Preserve the template method pattern**: Override specific methods rather than changing the overall algorithm
4. **Update templates appropriately**: Ensure any changes are reflected in templates

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the InfernoSuiteGenerator project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/beda-software/inferno_suite_generator/blob/main/CODE_OF_CONDUCT.md).