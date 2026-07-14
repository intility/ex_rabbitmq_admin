defmodule ExRabbitmqAdmin.ConnectionTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Connection

  @connection_name "127.0.0.1:5672 -> 127.0.0.1:49152"
  @username "guest"

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/connections"} ->
        %Tesla.Env{status: 200, body: [%{"name" => @connection_name}]}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/connections/#{@connection_name}"
      } ->
        %Tesla.Env{status: 200, body: %{"name" => @connection_name}}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/connections/#{@connection_name}"
      } ->
        %Tesla.Env{status: 204, body: ""}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/connections/username/#{@username}"
      } ->
        %Tesla.Env{status: 200, body: [%{"name" => @connection_name}]}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/connections/username/#{@username}"
      } ->
        %Tesla.Env{status: 204, body: ""}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/connections/#{@connection_name}/channels"
      } ->
        %Tesla.Env{status: 200, body: []}
    end)
  end

  test "can get a list of all open connections" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Connection.list_connections()
  end

  test "can get an individual connection by name" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Connection.get_connection(@connection_name)
  end

  test "can close a connection by name" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> Connection.delete_connection(@connection_name)
  end

  test "can list connections for a specific user" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Connection.list_user_connections(@username)
  end

  test "can close all connections for a specific user" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> Connection.delete_user_connections(@username)
  end

  test "can list channels for a specific connection" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Connection.list_connection_channels(@connection_name)
  end
end
