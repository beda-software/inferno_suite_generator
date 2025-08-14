# frozen_string_literal: true
require "json"

module InfernoSuiteGenerator
  module CreateTest

    def perform_create_test
      data_str = send(input_data)
      puts "data_str: #{data_str}"
      skip "No #{resource_type} resource provided for create test" if data_str.nil? || data_str.to_s.strip.empty?

      begin
        data_hash = JSON.parse(data_str)
      rescue JSON::ParserError => e
        assert false, "Input #{resource_type} JSON is invalid: #{e.message}"
      end

      resource_instance = FHIR.const_get(resource_type).new(data_hash)
      fhir_create(resource_type, resource: resource_instance)

      assert_response_status(201)
      assert_resource_type(resource_type)
      assert resource.id.present?, "Expected server to return an id for created #{resource_type}."
    end
  end
end
