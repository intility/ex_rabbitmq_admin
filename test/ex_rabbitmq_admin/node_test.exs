defmodule ExRabbitMQAdmin.NodeTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Node

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/nodes"} ->
        %Tesla.Env{
          status: 200,
          body: [
            %{"name" => "rabbit@rabbitmq1", "running" => true, "type" => "disc"},
            %{"name" => "rabbit@rabbitmq2", "running" => true, "type" => "disc"}
          ]
        }

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/nodes/rabbit@rabbitmq1"} ->
        %Tesla.Env{
          status: 200,
          body: %{"name" => "rabbit@rabbitmq1", "running" => true, "type" => "disc"}
        }
    end)
  end

  test "can list nodes" do
    assert {:ok, %Tesla.Env{status: 200, body: [%{"name" => "rabbit@rabbitmq1"} | _]}} =
             Client.client() |> Node.list_nodes()
  end

  test "can get a specific node" do
    assert {:ok,
            %Tesla.Env{status: 200, body: %{"name" => "rabbit@rabbitmq1", "running" => true}}} =
             Client.client() |> Node.get_node("rabbit@rabbitmq1")
  end

  test "raises ArgumentError when getting a node with invalid opts" do
    assert_raise ArgumentError, fn ->
      Client.client() |> Node.get_node("rabbit@rabbitmq1", invalid_opt: true)
    end
  end
end
