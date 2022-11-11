ExUnit.start()

defmodule TestHelper do
  defmodule Fixture do
    def read_json(filename) do
      File.read!("test/support/fixtures/#{filename}") |> Jason.decode!()
    end

    def read_fixture(filename) do
      File.read!("test/support/fixtures/#{filename}")
    end
  end
end
