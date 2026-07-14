defmodule ExRabbitMQAdmin.ExRabbitMQAdminTest do
  use ExRabbitMQAdmin.TestCase, async: true

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/overview"} ->
        %Tesla.Env{status: 200, body: %{"cluster_name" => "rabbit@rabbitmq"}}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/cluster-name"} ->
        %Tesla.Env{status: 200, body: %{"name" => "rabbit@rabbitmq"}}

      %{method: :put, url: "https://rabbitmq.example.com:5672/api/cluster-name"} ->
        %Tesla.Env{status: 204}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/extensions"} ->
        %Tesla.Env{status: 200, body: []}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/whoami"} ->
        %Tesla.Env{status: 200, body: %{"name" => "guest", "tags" => ["administrator"]}}

      %{method: :post, url: "https://rabbitmq.example.com:5672/api/rebalance/queues"} ->
        %Tesla.Env{status: 200, body: %{"ok" => "rebalance started"}}
    end)
  end

  test "can get overview" do
    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> ExRabbitMQAdmin.overview()
  end

  test "can get cluster name" do
    assert {:ok, %Tesla.Env{status: 200, body: %{"name" => "rabbit@rabbitmq"}}} =
             Client.client() |> ExRabbitMQAdmin.cluster_name()
  end

  test "can set cluster name" do
    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client() |> ExRabbitMQAdmin.put_cluster_name("my-cluster")
  end

  test "can get extensions" do
    assert {:ok, %Tesla.Env{status: 200, body: []}} =
             Client.client() |> ExRabbitMQAdmin.extensions()
  end

  test "can get whoami" do
    assert {:ok, %Tesla.Env{status: 200, body: %{"name" => "guest"}}} =
             Client.client() |> ExRabbitMQAdmin.whoami()
  end

  test "can rebalance queues" do
    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> ExRabbitMQAdmin.rebalance_queues()
  end
end
