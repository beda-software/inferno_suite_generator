# frozen_string_literal: true

module InfernoSuiteGenerator
  class Generator
    class IGDemodata
      attr_accessor :resource_ids, :resource_body_list, :patch_body_list

      def to_hash
        {
          resource_ids:,
          resource_body_list:,
          patch_body_list:
        }
      end
    end
  end
end
