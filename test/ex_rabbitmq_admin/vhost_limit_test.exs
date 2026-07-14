defmodule ExRabbitmqAdmin.VhostLimitTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.VhostLimit

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/vhost-limits"} ->
        %Tesla.Env{
          status: 200,
          body: [%{"vhost" => "my-vhost", "value" => %{"max-connections" => 100}}]
        }

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/vhost-limits/my-vhost"} ->
        %Tesla.Env{status: 200, body: %{"max-connections" => 100}}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/vhost-limits/my-vhost/max-connections"
      } ->
        %Tesla.Env{status: 200, body: 100}

      %{
        method: :put,
        url: "https://rabbitmq.example.com:5672/api/vhost-limits/my-vhost/max-connections"
      } ->
        %Tesla.Env{status: 204, body: ""}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/vhost-limits/my-vhost/max-connections"
      } ->
        %Tesla.Env{status: 204, body: ""}
    end)
  end

  test "can list vhost limits for all vhosts" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> VhostLimit.list_vhost_limits()
  end

  test "can get limits for a specific vhost" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> VhostLimit.get_vhost_limits("my-vhost")
  end

  test "can get a specific limit for a vhost" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> VhostLimit.get_vhost_limit("my-vhost", "max-connections")
  end

  test "can put a limit for a vhost" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> VhostLimit.put_vhost_limit("my-vhost", "max-connections", 100)
  end

  test "can delete a limit for a vhost" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> VhostLimit.delete_vhost_limit("my-vhost", "max-connections")
  end
end
