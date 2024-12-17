defmodule ExRabbitMQAdmin.ExchangeTest do
  use ExRabbitMQAdmin.TestCase, async: true
  import ExUnit.CaptureLog

  alias ExRabbitMQAdmin.Exchange

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/exchanges"} ->
        %Tesla.Env{status: 200, body: read_json("list_exchanges.json")}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/exchanges/my-vhost"} ->
        %Tesla.Env{status: 200, body: read_json("list_exchanges.json")}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/exchanges/unknown-vhost"} ->
        %Tesla.Env{status: 404, body: %{"error" => "Object Not Found", "reason" => "Not Found"}}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/exchanges/my-vhost/amq.direct"} ->
        %Tesla.Env{status: 200, body: read_json("get_exchange.json")}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/exchanges/my-vhost/unknown-exchange"
      } ->
        %Tesla.Env{status: 404, body: %{"error" => "Object Not Found", "reason" => "Not Found"}}

      %{
        method: :put,
        url: "https://rabbitmq.example.com:5672/api/exchanges/my-vhost/my-new-exchange"
      } ->
        %Tesla.Env{status: 201}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/exchanges/my-vhost/delete-me"
      } ->
        %Tesla.Env{status: 204}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/exchanges/my-vhost/amq.direct/bindings/source"
      } ->
        %Tesla.Env{status: 200, body: read_json("get_exchange_bindings_source.json")}

      %{
        method: :get,
        url:
          "https://rabbitmq.example.com:5672/api/exchanges/my-vhost/amq.fanout/bindings/destination"
      } ->
        %Tesla.Env{status: 200, body: read_json("get_exchange_bindings_destination.json")}

      %{
        method: :post,
        url: "https://rabbitmq.example.com:5672/api/exchanges/my-vhost/amq.direct/publish"
      } ->
        %Tesla.Env{status: 201, body: %{"routed" => true}}
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

    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> Exchange.list_exchanges(page: 1, page_size: 2)

    assert_raise ArgumentError,
                 "unknown options [:invalid_opt], valid options are: [:page, :page_size, :name, :use_regex]",
                 fn ->
                   Client.client() |> Exchange.list_exchanges(invalid_opt: "should-raise")
                 end
  end

  test "can list exchanges by vhost" do
    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> Exchange.list_vhost_exchanges("my-vhost")

    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> Exchange.list_vhost_exchanges("my-vhost", page: 1, page_size: 2)

    assert_raise ArgumentError,
                 "unknown options [:invalid_opt], valid options are: [:page, :page_size, :name, :use_regex]",
                 fn ->
                   Client.client()
                   |> Exchange.list_vhost_exchanges("my-vhost", invalid_opt: "should-raise")
                 end

    assert {:ok,
            %Tesla.Env{
              status: 404,
              body: %{"error" => "Object Not Found", "reason" => "Not Found"}
            }} = Client.client() |> Exchange.list_vhost_exchanges("unknown-vhost")
  end

  test "can get a single exchange on vhost by name" do
    assert {:ok, %Tesla.Env{status: 200, body: %{"name" => "amq.direct", "vhost" => "my-vhost"}}} =
             Client.client() |> Exchange.get_exchange("my-vhost", "amq.direct")

    assert {:ok,
            %Tesla.Env{
              status: 404,
              body: %{"error" => "Object Not Found", "reason" => "Not Found"}
            }} = Client.client() |> Exchange.get_exchange("my-vhost", "unknown-exchange")
  end

  test "can create a new exchange" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client() |> Exchange.put_exchange("my-vhost", "my-new-exchange")

    assert_raise ArgumentError,
                 "unknown options [:invalid_opt], valid options are: [:arguments, :auto_delete, :durable, :internal, :type]",
                 fn ->
                   Client.client()
                   |> Exchange.put_exchange("my-vhost", "my-new-exchange",
                     invalid_opt: "should-raise"
                   )
                 end
  end

  test "can delete an exchange" do
    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client() |> Exchange.delete_exchange("my-vhost", "delete-me")

    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client()
             |> Exchange.delete_exchange("my-vhost", "delete-me", if_unused: true)

    assert_raise ArgumentError,
                 "unknown options [:invalid_opt], valid options are: [:if_unused]",
                 fn ->
                   Client.client()
                   |> Exchange.delete_exchange("my-vhost", "delete-me",
                     invalid_opt: "should-raise"
                   )
                 end
  end

  test "can list exchange source bindings" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: [
                %{
                  "arguments" => %{},
                  "destination" => "my-fine-queue",
                  "destination_type" => "queue",
                  "properties_key" => "plastic-patas-monkey",
                  "routing_key" => "plastic-patas-monkey",
                  "source" => "amq.direct",
                  "vhost" => "my-vhost"
                }
              ]
            }} = Client.client() |> Exchange.list_exchange_src_bindings("my-vhost", "amq.direct")
  end

  test "can list exchange destination bindings" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: [
                %{
                  "arguments" => %{},
                  "destination" => "amq.fanout",
                  "destination_type" => "exchange",
                  "properties_key" => "unpleasant-hamster",
                  "routing_key" => "unpleasant-hamster",
                  "source" => "amq.direct",
                  "vhost" => "my-vhost"
                }
              ]
            }} = Client.client() |> Exchange.list_exchange_dest_bindings("my-vhost", "amq.fanout")
  end

  test "can publish message to exchange" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client()
             |> Exchange.publish_message("my-vhost", "amq.direct",
               routing_key: "reliable-lemming",
               payload: "Hello, world!"
             )

    assert_raise ArgumentError,
                 "required :routing_key option not found, received options: [:payload]",
                 fn ->
                   Client.client()
                   |> Exchange.publish_message("my-vhost", "amq.direct", payload: "Hello, world!")
                 end
  end
end
