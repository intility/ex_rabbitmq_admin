defmodule ExRabbitmqAdmin.PolicyTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Policy

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/policies"} ->
        %Tesla.Env{status: 200, body: [%{"vhost" => "my-vhost", "name" => "my-policy"}]}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/policies/my-vhost"} ->
        %Tesla.Env{status: 200, body: [%{"vhost" => "my-vhost", "name" => "my-policy"}]}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/policies/my-vhost/my-policy"
      } ->
        %Tesla.Env{status: 200, body: %{"vhost" => "my-vhost", "name" => "my-policy"}}

      %{
        method: :put,
        url: "https://rabbitmq.example.com:5672/api/policies/my-vhost/my-policy"
      } ->
        %Tesla.Env{status: 201}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/policies/my-vhost/my-policy"
      } ->
        %Tesla.Env{status: 204, body: ""}
    end)
  end

  test "can get a list of all policies" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Policy.list_policies()
  end

  test "can get a list of policies in a vhost" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Policy.list_vhost_policies("my-vhost")
  end

  test "can get an individual policy" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Policy.get_policy("my-vhost", "my-policy")
  end

  test "can create a policy" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client()
             |> Policy.put_policy("my-vhost", "my-policy",
               pattern: "^amq.",
               definition: %{"ha-mode" => "all"}
             )
  end

  test "raises ArgumentError when creating a policy with invalid opts" do
    assert_raise ArgumentError, fn ->
      Client.client()
      |> Policy.put_policy("my-vhost", "my-policy", pattern: "^amq.")
    end
  end

  test "can delete a policy" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> Policy.delete_policy("my-vhost", "my-policy")
  end
end
