# frozen_string_literal: true

module InfernoSuiteGenerator
  class Generator
    module SpecialCases
      RESOURCES_TO_EXCLUDE = %w[
        Medication
        DiagnosticReport
      ].freeze

      VERSION_SPECIFIC_RESOURCES_TO_EXCLUDE = {
        'v1.0.0' => %w[Medication RelatedPerson]
      }.freeze

      PROFILES_TO_EXCLUDE = [].freeze

      PATIENT_IDENTIFIERS = [
        { display: 'IHI', url: 'http://ns.electronichealth.net.au/id/hi/ihi/1.0' },
        { display: 'Medicare', url: 'http://ns.electronichealth.net.au/id/medicare-number' },
        { display: 'DVA', url: 'http://ns.electronichealth.net.au/id/dva' }
      ].freeze

      PRACTITIONER_IDENTIFIERS = [
        { display: 'HPI-I', url: 'http://ns.electronichealth.net.au/id/hi/hpii/1.0' }
      ].freeze

      PRACTITIONER_ROLE_IDENTIFIERS = [
        { display: 'Medicare', url: 'http://ns.electronichealth.net.au/id/medicare-provider-number' }
      ].freeze

      ORGANIZATION_IDENTIFIERS = [
        { display: 'HPI-O', url: 'http://ns.electronichealth.net.au/id/hi/hpio/1.0' },
        { display: 'ABN', url: 'http://hl7.org.au/id/abn' }
      ].freeze

      # In the current implementation (2024.10.16/1.0.0-ci-build) there is no way
      # to get information on what search/combo search parameters SHOULD be supported
      # with the _include parameter. This information exists only in narratives.

      # https://build.fhir.org/ig/hl7au/au-fhir-core/StructureDefinition-au-core-medicationrequest.html#mandatory-search-parameters
      # https://build.fhir.org/ig/hl7au/au-fhir-core/StructureDefinition-au-core-practitionerrole.html#mandatory-search-parameters
      # https://github.com/hl7au/au-fhir-core-inferno/issues/199

      SEARCH_PARAMS_FOR_INCLUDE_BY_RESOURCE = {
        'MedicationStatement' => [
          ['medication']
        ],
        'MedicationRequest' => [
          ['patient'],
          %w[patient intent],
          %w[patient intent status],
          ['_id'],
          %w[patient intent authoredon]
        ],
        'PractitionerRole' => [
          ['identifier'],
          ['practitioner'],
          ['_id'],
          ['specialty']
        ]
      }.freeze

      MULTIPLE_OR_AND_SEARCH_BY_TARGET_RESOURCE = {
        'PractitionerRole' => [['practitioner']]
      }.freeze
    end
  end
end
