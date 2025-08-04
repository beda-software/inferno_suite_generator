# Inferno Suite Generator Configuration Guide

This guide provides a comprehensive overview of the configuration file used by the Inferno Suite Generator. The configuration file controls how test suites are generated, what resources and profiles are tested, and how various tests behave.

## Table of Contents

- [Overview](#overview)
- [Configuration File Structure](#configuration-file-structure)
  - [Implementation Guide (ig)](#implementation-guide-ig)
  - [Suite Configuration](#suite-configuration)
  - [Constants](#constants)
  - [Configs](#configs)
    - [Generic Configuration](#generic-configuration)
    - [Profiles Configuration](#profiles-configuration)
    - [Resources Configuration](#resources-configuration)
- [Common Configuration Patterns](#common-configuration-patterns)
- [Best Practices](#best-practices)

## Overview

The Inferno Suite Generator uses a JSON configuration file to define how test suites should be generated for FHIR Implementation Guides. This configuration controls everything from basic metadata about the Implementation Guide to specific test behavior for individual resources and profiles.

A typical workflow involves:
1. Creating a configuration file based on your Implementation Guide requirements
2. Running the Inferno Suite Generator with this configuration
3. Executing the generated test suite against FHIR servers

## Configuration File Structure

The configuration file is structured into four main sections:

```
{
  "ig": { ... },  // Implementation Guide metadata
  "suite": { ... },  // Suite configuration
  "constants": { ... },  // Reusable constant values
  "configs": { ... }  // Test configurations
}
```

Let's explore each section in detail.

### Implementation Guide (ig)

The `ig` section contains metadata about the Implementation Guide being tested:

```
"ig": {
  "id": "hl7.fhir.au.core",
  "version": "2.0.0-draft",
  "name": "AU Core Implementation Guide",
  "link": "https://hl7.org.au/fhir/core/2.0.0-draft/index.html",
  "cs_profile_url": "http://hl7.org.au/fhir/core/CapabilityStatement/au-core-responder",
  "cs_version_specific_url": "https://hl7.org.au/fhir/core/2.0.0-draft/CapabilityStatement-au-core-responder.html"
}
```

| Field | Description |
|-------|-------------|
| `id` | The identifier of the Implementation Guide |
| `version` | The version of the Implementation Guide |
| `name` | The human-readable name of the Implementation Guide |
| `link` | URL to the Implementation Guide documentation |
| `cs_profile_url` | URL to the CapabilityStatement profile |
| `cs_version_specific_url` | Version-specific URL to the CapabilityStatement |

### Suite Configuration

The `suite` section defines the overall test suite configuration:

```
"suite": {
  "title": "AU Core",
  "extra_json_paths": ["search-params.json"],
  "tx_server_url": "https://tx.dev.hl7.org.au/fhir",
  "outer_groups": [ ... ],
  "links": [ ... ]
}
```

| Field | Description |
|-------|-------------|
| `title` | The title of the test suite |
| `extra_json_paths` | Additional JSON files to include |
| `tx_server_url` | URL to the terminology server |
| `outer_groups` | Custom test groups to include |
| `links` | External links to include in the test suite UI |

#### Outer Groups

The `outer_groups` array allows you to include custom test groups:

```
"outer_groups": [
  {
    "import_type": "relative",
    "import_path": "../../custom_groups/capability_statement/capability_statement_group",
    "group_position": "before",
    "group_id": "au_core_capability_statement"
  }
]
```

| Field | Description |
|-------|-------------|
| `import_type` | Type of import (e.g., "relative") |
| `import_path` | Path to the custom group |
| `group_position` | Position of the group ("before" or "after") |
| `group_id` | Identifier for the group |

#### Links

The `links` array defines external links to include in the test suite UI:

```
"links": [
  {
    "label": "Report Issue",
    "url": "https://github.com/hl7au/au-fhir-core-inferno/issues"
  }
]
```

| Field | Description |
|-------|-------------|
| `label` | Display text for the link |
| `url` | URL the link points to |

### Constants

The `constants` section defines reusable values that can be referenced throughout the configuration:

```
"constants": {
  "default_fhir_server": "https://fhir.hl7.org.au/aucore/fhir/DEFAULT",
  "read_ids.patient": "baratz-toni, irvine-ronny-lawrence, italia-sofia",
  "search_default_values.date": ["ge1950-01-01", "le2050-01-01", "gt1950-01-01", "lt2050-01-01"],
  "search.comparators": ["gt", "lt", "ge", "le"]
}
```

Common constants include:
- `default_fhir_server`: Default FHIR server URL
- `read_ids.*`: Resource IDs for read tests
- `search_default_values.*`: Default values for search parameters
- `search.comparators`: Supported search comparators

### Configs

The `configs` section contains the bulk of the configuration, divided into three subsections:

```
"configs": {
  "generic": { ... },
  "profiles": { ... },
  "resources": { ... }
}
```

#### Generic Configuration

The `generic` subsection defines configuration that applies to all tests:

```
"generic": {
  "expectation": ["SHALL", "SHOULD", "MAY"],
  "search_params_to_ignore": ["count", "_sort", "_include"]
}
```

| Field | Description |
|-------|-------------|
| `expectation` | Levels of requirement to test (SHALL, SHOULD, MAY) |
| `search_params_to_ignore` | Search parameters to exclude from testing |

#### Profiles Configuration

The `profiles` subsection configures testing for specific FHIR profiles:

```
"profiles": {
  "http://hl7.org.au/fhir/core/StructureDefinition/au-core-patient": {
    "first_class_profile": "search",
    "override_executor": {
      "search": {
        "identifier": "run_search_test_with_system"
      }
    }
  }
}
```

Common profile configurations include:
- `first_class_profile`: Designates a profile as primary for testing
- `skip`: Set to `true` to skip testing a profile
- `must_support`: Configure must-support element testing
- `search_param`: Configure search parameter testing
- `extra_searches`: Define additional search combinations to test
- `forced_initial_search`: Define parameters for initial search

Example of removing elements from must-support testing:

```
"must_support": {
  "remove_elements": [
    {
      "element_key": "path",
      "condition": "pattern_match?",
      "value": "(component(:[^.]+)?\\.)?dataAbsentReason"
    }
  ]
}
```

Example of configuring extra searches:

```
"extra_searches": [
  {
    "type": "search",
    "params": ["patient", "intent"]
  },
  {
    "type": "include",
    "param": "medication",
    "target_resource": "Medication",
    "paths": ["medicationReference"]
  }
]
```

#### Resources Configuration

The `resources` subsection configures testing for specific FHIR resource types:

```
"resources": {
  "Patient": {
    "search_param": {
      "identifier": {
        "extra_tests_with": [
          {
            "display": "IHI",
            "url": "http://ns.electronichealth.net.au/id/hi/ihi/1.0"
          }
        ]
      },
      "individual-birthdate": {
        "default_values": "search_default_values.date",
        "multiple_and_expectation": "MAY",
        "comparators": "search.comparators"
      }
    }
  }
}
```

Common resource configurations include:
- `skip`: Set to `true` to skip testing a resource
- `search_param`: Configure search parameter testing
- `search_multiple_or_and_by_target_resource`: Configure chained search testing
- `forced_initial_search`: Define parameters for initial search

## Common Configuration Patterns

### Configuring Search Parameters

Search parameters can be configured with various options:

```
"search_param": {
  "clinical-date": {
    "default_values": "search_default_values.datetime",
    "multiple_and_expectation": "SHOULD",
    "comparators": "search.comparators"
  },
  "Observation-status": {
    "multiple_or_expectation": "SHALL"
  }
}
```

| Option | Description |
|--------|-------------|
| `default_values` | Reference to predefined values in constants |
| `multiple_and_expectation` | Expectation level for AND searches |
| `multiple_or_expectation` | Expectation level for OR searches |
| `comparators` | Reference to supported comparators |
| `expectation_change` | Override the expectation level |
| `extra_tests_with` | Additional system-specific tests |

### Configuring Must-Support Elements

Must-support elements can be configured to exclude certain elements:

```
"must_support": {
  "remove_elements": [
    {
      "element_key": "path",
      "condition": "pattern_match?",
      "value": "(component(:[^.]+)?\\.)?dataAbsentReason"
    },
    {
      "element_key": "path",
      "condition": "equal",
      "value": "method"
    }
  ]
}
```

| Option | Description |
|--------|-------------|
| `element_key` | The element attribute to match |
| `condition` | The condition to apply (e.g., "pattern_match?", "equal", "start_with?") |
| `value` | The value to match against |

## Best Practices

1. **Start with an example**: Use the provided `config.example.json` as a starting point
2. **Organize constants**: Define reusable values in the constants section
3. **Test incrementally**: Start with a minimal configuration and add complexity
4. **Document customizations**: Add comments to explain non-standard configurations
5. **Version control**: Keep your configuration under version control
6. **Validate JSON**: Ensure your JSON is valid before running the generator
7. **Review generated tests**: Inspect the generated tests to ensure they match expectations

By following this guide, you should be able to create and customize configurations for the Inferno Suite Generator to test FHIR Implementation Guides effectively.