# frozen_string_literal: true

module InfernoSuiteGenerator
  class Generator
    class GeneratorConfigKeeper
      module GeneratorConfigKeeperGetters
        def get(path, default = nil)
          # TODO: Remove
          @config.dig(*path.split(".")) || default
        end

        def get_new(path, default = nil)
          @config.dig(*path.split("&.")) || default
        end

        def tx_server_url
          get("suite.tx_server_url")
        end

        def paths
          get("suite.paths", {})
        end

        def resources_configs
          get("configs.resources", {})
        end

        def ig_link
          get("ig.link")
        end

        def ig_name
          get("ig.name")
        end

        def cs_profile_url
          get("ig.cs_profile_url")
        end

        def cs_version_specific_url
          get("ig.cs_version_specific_url")
        end

        def id
          get("ig.id")
        end

        def title
          get("suite.title")
        end

        def default_fhir_server
          get("constants.default_fhir_server")
        end

        def links
          get("suite.links", [])
        end

        def package_archive_path
          get("ig.package_archive_path", nil)
        end

        def extra_json_paths
          get("suite.extra_json_paths", [])
        end

        def search_params_to_ignore
          get("configs.generic.search_params_to_ignore", [])
        end

        def search_params_expectation
          get("configs.generic.expectation", [])
        end

        def constants
          get("constants", {})
        end

        def outer_groups
          get("suite.outer_groups", [])
        end
      end
    end
  end
end
