# frozen_string_literal: true

require "fhir_models"

# Decorator class for FHIR::R4::Bundle::Entry that provides additional
# utility methods for working with parameter parts and extracting values.
class BundleEntryDecorator < FHIR::R4::Bundle::Entry
  def initialize(bundle_entry)
    super()
    @bundle_entry = bundle_entry
  end

  def bundle_entry_patch_parameter?(resource_type)
    request = @bundle_entry.request

    is_patch = request.local_method == "PATCH"
    for_target_resource = request.url.split("/").first == resource_type
    resource_type_is_parameters = @bundle_entry.resource.resourceType == "Parameters"

    is_patch && for_target_resource && resource_type_is_parameters
  end
end
