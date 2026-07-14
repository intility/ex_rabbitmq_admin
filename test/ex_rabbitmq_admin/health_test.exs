defmodule ExRabbitmqAdmin.HealthTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Health

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/aliveness-test/my-vhost"} ->
        %Tesla.Env{status: 200, body: %{"status" => "ok"}}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/health/checks/alarms"} ->
        %Tesla.Env{status: 200, body: %{"status" => "ok"}}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/health/checks/local-alarms"} ->
        %Tesla.Env{status: 200, body: %{"status" => "ok"}}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/health/checks/certificate-expiration/30/days"
      } ->
        %Tesla.Env{status: 200, body: %{"status" => "ok"}}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/health/checks/port-listener/5672"
      } ->
        %Tesla.Env{status: 200, body: %{"status" => "ok"}}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/health/checks/protocol-listener/amqp"
      } ->
        %Tesla.Env{status: 200, body: %{"status" => "ok"}}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/health/checks/virtual-hosts"} ->
        %Tesla.Env{status: 200, body: %{"status" => "ok"}}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/health/checks/node-is-mirror-sync-critical"
      } ->
        %Tesla.Env{status: 200, body: %{"status" => "ok"}}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/health/checks/node-is-quorum-critical"
      } ->
        %Tesla.Env{status: 200, body: %{"status" => "ok"}}
    end)
  end

  test "can perform a basic aliveness test" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Health.aliveness_test("my-vhost")
  end

  test "can check for resource alarms in the cluster" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Health.check_alarms()
  end

  test "can check for local resource alarms on the target node" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Health.check_local_alarms()
  end

  test "can check for certificate expiration within a time window" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Health.check_certificate_expiration(30, "days")
  end

  test "can check for an active listener on a given port" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Health.check_port_listener(5672)
  end

  test "can check for an active listener for a given protocol" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Health.check_protocol_listener("amqp")
  end

  test "can check that all virtual hosts and their resources are running" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Health.check_virtual_hosts()
  end

  test "can check for classic mirrored queues without synchronised mirrors online" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Health.check_mirror_sync_critical()
  end

  test "can check for quorum queues with minimum online quorum" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Health.check_quorum_critical()
  end
end
