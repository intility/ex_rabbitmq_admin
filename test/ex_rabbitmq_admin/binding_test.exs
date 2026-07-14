defmodule ExRabbitMQAdmin.BindingTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Binding

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/bindings"} ->
        %Tesla.Env{status: 200, body: read_json("list_bindings.json")}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/bindings/my-vhost"} ->
        %Tesla.Env{status: 200, body: read_json("list_bindings.json")}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/bindings/my-vhost/e/my-exchange/q/my-queue"
      } ->
        %Tesla.Env{status: 200, body: [%{"properties_key" => "my-props"}]}

      %{
        method: :post,
        url: "https://rabbitmq.example.com:5672/api/bindings/my-vhost/e/my-exchange/q/my-queue"
      } ->
        %Tesla.Env{
          status: 201,
          headers: [{"location", "/api/bindings/my-vhost/e/my-exchange/q/my-queue/my-props"}]
        }

      %{
        method: :get,
        url:
          "https://rabbitmq.example.com:5672/api/bindings/my-vhost/e/my-exchange/q/my-queue/my-props"
      } ->
        %Tesla.Env{status: 200, body: %{"properties_key" => "my-props"}}

      %{
        method: :delete,
        url:
          "https://rabbitmq.example.com:5672/api/bindings/my-vhost/e/my-exchange/q/my-queue/my-props"
      } ->
        %Tesla.Env{status: 204, body: ""}

      %{
        method: :get,
        url:
          "https://rabbitmq.example.com:5672/api/bindings/my-vhost/e/src-exchange/e/dest-exchange"
      } ->
        %Tesla.Env{status: 200, body: [%{"properties_key" => "my-props"}]}

      %{
        method: :post,
        url:
          "https://rabbitmq.example.com:5672/api/bindings/my-vhost/e/src-exchange/e/dest-exchange"
      } ->
        %Tesla.Env{
          status: 201,
          headers: [
            {"location", "/api/bindings/my-vhost/e/src-exchange/e/dest-exchange/my-props"}
          ]
        }

      %{
        method: :get,
        url:
          "https://rabbitmq.example.com:5672/api/bindings/my-vhost/e/src-exchange/e/dest-exchange/my-props"
      } ->
        %Tesla.Env{status: 200, body: %{"properties_key" => "my-props"}}

      %{
        method: :delete,
        url:
          "https://rabbitmq.example.com:5672/api/bindings/my-vhost/e/src-exchange/e/dest-exchange/my-props"
      } ->
        %Tesla.Env{status: 204, body: ""}
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

  test "can list vhost bindings" do
    assert {:ok, %Tesla.Env{status: 200, body: [_ | _]}} =
             Client.client() |> Binding.list_vhost_bindings("my-vhost")
  end

  test "can list exchange-to-queue bindings" do
    assert {:ok, %Tesla.Env{status: 200, body: [%{"properties_key" => "my-props"}]}} =
             Client.client()
             |> Binding.list_exchange_queue_bindings("my-vhost", "my-exchange", "my-queue")
  end

  test "can create an exchange-to-queue binding" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client()
             |> Binding.create_exchange_queue_binding(
               "my-vhost",
               "my-exchange",
               "my-queue",
               routing_key: "my-routing-key"
             )
  end

  test "raises ArgumentError when creating exchange-to-queue binding with invalid opts" do
    assert_raise ArgumentError, fn ->
      Client.client()
      |> Binding.create_exchange_queue_binding(
        "my-vhost",
        "my-exchange",
        "my-queue",
        invalid_opt: true
      )
    end
  end

  test "can get an individual exchange-to-queue binding" do
    assert {:ok, %Tesla.Env{status: 200, body: %{"properties_key" => "my-props"}}} =
             Client.client()
             |> Binding.get_exchange_queue_binding(
               "my-vhost",
               "my-exchange",
               "my-queue",
               "my-props"
             )
  end

  test "can delete an exchange-to-queue binding" do
    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client()
             |> Binding.delete_exchange_queue_binding(
               "my-vhost",
               "my-exchange",
               "my-queue",
               "my-props"
             )
  end

  test "can list exchange-to-exchange bindings" do
    assert {:ok, %Tesla.Env{status: 200, body: [%{"properties_key" => "my-props"}]}} =
             Client.client()
             |> Binding.list_exchange_exchange_bindings(
               "my-vhost",
               "src-exchange",
               "dest-exchange"
             )
  end

  test "can create an exchange-to-exchange binding" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client()
             |> Binding.create_exchange_exchange_binding(
               "my-vhost",
               "src-exchange",
               "dest-exchange",
               routing_key: "my-routing-key"
             )
  end

  test "raises ArgumentError when creating exchange-to-exchange binding with invalid opts" do
    assert_raise ArgumentError, fn ->
      Client.client()
      |> Binding.create_exchange_exchange_binding(
        "my-vhost",
        "src-exchange",
        "dest-exchange",
        invalid_opt: true
      )
    end
  end

  test "can get an individual exchange-to-exchange binding" do
    assert {:ok, %Tesla.Env{status: 200, body: %{"properties_key" => "my-props"}}} =
             Client.client()
             |> Binding.get_exchange_exchange_binding(
               "my-vhost",
               "src-exchange",
               "dest-exchange",
               "my-props"
             )
  end

  test "can delete an exchange-to-exchange binding" do
    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client()
             |> Binding.delete_exchange_exchange_binding(
               "my-vhost",
               "src-exchange",
               "dest-exchange",
               "my-props"
             )
  end
end
