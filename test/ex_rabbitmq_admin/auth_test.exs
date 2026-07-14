defmodule ExRabbitmqAdmin.AuthTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Auth

  @node "rabbit@node1"

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/auth"} ->
        %Tesla.Env{status: 200, body: %{"oauth_client_id" => "rabbit_client"}}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/auth/attempts/#{@node}"
      } ->
        %Tesla.Env{status: 200, body: []}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/auth/attempts/#{@node}/source"
      } ->
        %Tesla.Env{status: 200, body: []}
    end)
  end

  test "can get OAuth2 configuration details" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Auth.get_auth()
  end

  test "can list authentication attempts on a node" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Auth.list_auth_attempts(@node)
  end

  test "can list authentication attempts by source on a node" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Auth.list_auth_attempts_by_source(@node)
  end
end
