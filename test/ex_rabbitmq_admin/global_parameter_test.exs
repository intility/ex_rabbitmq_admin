defmodule ExRabbitmqAdmin.GlobalParameterTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.GlobalParameter

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/global-parameters"} ->
        %Tesla.Env{status: 200, body: []}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/global-parameters/my-global-param"
      } ->
        %Tesla.Env{status: 200, body: %{"name" => "my-global-param"}}

      %{
        method: :put,
        url: "https://rabbitmq.example.com:5672/api/global-parameters/my-global-param"
      } ->
        %Tesla.Env{status: 201}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/global-parameters/my-global-param"
      } ->
        %Tesla.Env{status: 204, body: ""}
    end)
  end

  test "can get a list of all global parameters" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> GlobalParameter.list_global_parameters()
  end

  test "can get a specific global parameter" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> GlobalParameter.get_global_parameter("my-global-param")
  end

  test "can set a specific global parameter" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client()
             |> GlobalParameter.put_global_parameter("my-global-param", "some-value")
  end

  test "can delete a specific global parameter" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> GlobalParameter.delete_global_parameter("my-global-param")
  end
end
