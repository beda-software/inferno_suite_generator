module InfernoSuiteGenerator
  module GenericUtils
    def camel_to_snake(str)
      str.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase
    end

    module_function :camel_to_snake
  end
end
