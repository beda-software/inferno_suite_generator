# frozen_string_literal: true

module GenericUtils
  def camel_to_snake(str)
    str.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase
  end

  def test_input_builder(id, title, description, default_value)
    {
      "input_id" => id,
      "title" => title,
      "description" => description,
      "default" => default_value
    }
  end

  module_function :camel_to_snake, :test_input_builder
end
