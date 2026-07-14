defmodule ExRabbitmqAdmin.OperatorPolicyTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.OperatorPolicy

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/operator-policies"} ->
        %Tesla.Env{status: 200, body: [%{"vhost" => "my-vhost", "name" => "my-operator-policy"}]}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/operator-policies/my-vhost"} ->
        %Tesla.Env{status: 200, body: [%{"vhost" => "my-vhost", "name" => "my-operator-policy"}]}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/operator-policies/my-vhost/my-operator-policy"
      } ->
        %Tesla.Env{status: 200, body: %{"vhost" => "my-vhost", "name" => "my-operator-policy"}}

      %{
        method: :put,
        url: "https://rabbitmq.example.com:5672/api/operator-policies/my-vhost/my-operator-policy"
      } ->
        %Tesla.Env{status: 201}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/operator-policies/my-vhost/my-operator-policy"
      } ->
        %Tesla.Env{status: 204, body: ""}
    end)
  end

  test "can get a list of all operator policies" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> OperatorPolicy.list_operator_policies()
  end

  test "can get a list of operator policies in a vhost" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> OperatorPolicy.list_vhost_operator_policies("my-vhost")
  end

  test "can get an individual operator policy" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client()
             |> OperatorPolicy.get_operator_policy("my-vhost", "my-operator-policy")
  end

  test "can create an operator policy" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client()
             |> OperatorPolicy.put_operator_policy("my-vhost", "my-operator-policy",
               pattern: "^amq.",
               definition: %{"ha-mode" => "all"}
             )
  end

  test "raises ArgumentError when creating an operator policy with invalid opts" do
    assert_raise ArgumentError, fn ->
      Client.client()
      |> OperatorPolicy.put_operator_policy("my-vhost", "my-operator-policy", pattern: "^amq.")
    end
  end

  test "can delete an operator policy" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client()
             |> OperatorPolicy.delete_operator_policy("my-vhost", "my-operator-policy")
  end
end
