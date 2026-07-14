defmodule ExRabbitmqAdmin.UserLimitTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.UserLimit

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/user-limits"} ->
        %Tesla.Env{
          status: 200,
          body: [%{"user" => "guest", "value" => %{"max-connections" => 100}}]
        }

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/user-limits/guest"} ->
        %Tesla.Env{status: 200, body: %{"max-connections" => 100}}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/user-limits/guest/max-connections"
      } ->
        %Tesla.Env{status: 200, body: 100}

      %{
        method: :put,
        url: "https://rabbitmq.example.com:5672/api/user-limits/guest/max-connections"
      } ->
        %Tesla.Env{status: 204, body: ""}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/user-limits/guest/max-connections"
      } ->
        %Tesla.Env{status: 204, body: ""}
    end)
  end

  test "can list user limits for all users" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> UserLimit.list_user_limits()
  end

  test "can get limits for a specific user" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> UserLimit.get_user_limits("guest")
  end

  test "can get a specific limit for a user" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> UserLimit.get_user_limit("guest", "max-connections")
  end

  test "can put a limit for a user" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> UserLimit.put_user_limit("guest", "max-connections", 100)
  end

  test "can delete a limit for a user" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> UserLimit.delete_user_limit("guest", "max-connections")
  end
end
