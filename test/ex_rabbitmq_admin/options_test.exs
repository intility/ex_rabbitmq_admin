defmodule ExRabbitMQAdmin.OptionsTest do
  use ExUnit.Case, async: true

  alias ExRabbitMQAdmin.Options

  test "format_error with empty keys_path returns message directly" do
    error = %NimbleOptions.ValidationError{keys_path: [], message: "some error"}
    assert Options.format_error(error) == "some error"
  end

  test "format_error with non-empty keys_path includes key path" do
    error = %NimbleOptions.ValidationError{keys_path: [:nested_key], message: "bad value"}
    assert Options.format_error(error) == "invalid parameter for key [:nested_key], bad value"
  end
end
