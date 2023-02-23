defmodule ExRabbitMQAdmin.ExchangeTest do
  use ExRabbitMQAdmin.TestCase, async: true
  import ExUnit.CaptureLog

  alias ExRabbitMQAdmin.Exchange

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/exchanges"} ->
        %Tesla.Env{status: 200, body: read_json("list_exchanges.json")}
    end)
  end

  test "can list exchanges" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: [
                %{
                  "name" => "",
                  "type" => "direct",
                  "user_who_performed_action" => "rmq-internal",
                  "vhost" => "/"
                }
                | _rest
              ]
            }} = Client.client() |> Exchange.list_exchanges()
  end
end
