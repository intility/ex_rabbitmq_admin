defmodule ExRabbitmqAdmin.ParameterTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Parameter

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/parameters"} ->
        %Tesla.Env{status: 200, body: []}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/parameters/federation"} ->
        %Tesla.Env{status: 200, body: []}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/parameters/federation/my-vhost"
      } ->
        %Tesla.Env{status: 200, body: []}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/parameters/federation/my-vhost/my-param"
      } ->
        %Tesla.Env{status: 200, body: %{"name" => "my-param"}}

      %{
        method: :put,
        url: "https://rabbitmq.example.com:5672/api/parameters/federation/my-vhost/my-param"
      } ->
        %Tesla.Env{status: 201}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/parameters/federation/my-vhost/my-param"
      } ->
        %Tesla.Env{status: 204, body: ""}
    end)
  end

  test "can get a list of all parameters" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Parameter.list_parameters()
  end

  test "can get a list of parameters for a component" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Parameter.list_component_parameters("federation")
  end

  test "can get a list of parameters for a component on a specific vhost" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client()
             |> Parameter.list_component_vhost_parameters("federation", "my-vhost")
  end

  test "can get a specific parameter" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Parameter.get_parameter("federation", "my-vhost", "my-param")
  end

  test "can set a specific parameter" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client()
             |> Parameter.put_parameter("federation", "my-vhost", "my-param", %{
               "uri" => "amqp://"
             })
  end

  test "can delete a specific parameter" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> Parameter.delete_parameter("federation", "my-vhost", "my-param")
  end
end
