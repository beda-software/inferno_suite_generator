# frozen_string_literal: true

module InfernoSuiteGenerator
  class Generator
    class IGDemodata
      attr_accessor :resource_ids, :resource_body_list, :patch_body_list

      def initialize(data = nil)
        return unless data

        @resource_ids = data.is_a?(Hash) ? (data['resource_ids'] || data[:resource_ids]) : nil
        @resource_body_list = data.is_a?(Hash) ? (data['resource_body_list'] || data[:resource_body_list]) : nil
        @patch_body_list = data.is_a?(Hash) ? (data['patch_body_list'] || data[:patch_body_list]) : nil
      end

      def to_hash
        {
          resource_ids: resource_ids,
          resource_body_list: resource_body_list,
          patch_body_list: patch_body_list
        }
      end
    end
  end
end
