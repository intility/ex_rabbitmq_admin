defmodule ExRabbitMQAdmin.DefinitionTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Definition

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/definitions"} ->
        %Tesla.Env{status: 200, body: %{"queues" => [], "exchanges" => []}}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/definitions/my-vhost"} ->
        %Tesla.Env{status: 200, body: %{"queues" => [], "exchanges" => []}}

      %{method: :post, url: "https://rabbitmq.example.com:5672/api/definitions"} ->
        %Tesla.Env{status: 200}

      %{method: :post, url: "https://rabbitmq.example.com:5672/api/definitions/my-vhost"} ->
        %Tesla.Env{status: 200}
    end)
  end

  test "can list definitions" do
    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> Definition.list_definitions()
  end

  test "can list vhost definitions" do
    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> Definition.list_vhost_definitions("my-vhost")
  end

  test "can upload definitions" do
    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client()
             |> Definition.upload_definitions(%{"queues" => [], "exchanges" => []})
  end

  test "can upload vhost definitions" do
    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client()
             |> Definition.upload_vhost_definitions("my-vhost", %{"queues" => []})
  end
end
