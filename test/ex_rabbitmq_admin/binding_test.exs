defmodule ExRabbitMQAdmin.BindingTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Binding

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/bindings"} ->
        %Tesla.Env{status: 200, body: read_json("list_bindings.json")}
    end)
  end

  test "can list bindings" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: [
                %{
                  "arguments" => %{},
                  "destination" => "dumpster-fire",
                  "destination_type" => "queue",
                  "properties_key" => "dumpster-fire",
                  "routing_key" => "dumpster-fire",
                  "source" => "",
                  "vhost" => "my-vhost"
                }
                | _rest
              ]
            }} = Client.client() |> Binding.list_bindings()
  end
end
