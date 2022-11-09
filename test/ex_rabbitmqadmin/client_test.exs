defmodule ExRabbitMQAdminTest.Client do
  # https://rawcdn.githack.com/rabbitmq/rabbitmq-server/v3.11.2/deps/rabbitmq_management/priv/www/api/index.html
  use ExUnit.Case, async: true

  import Tesla.Mock
  alias ExRabbitMQAdmin.Client

  setup do
    Application.put_env(:ex_rabbitmqadmin, ExRabbitMQAdmin.Client,
      base_url: "https://rabbitmq.example.com:5672",
      username: "guest",
      password: "guest"
    )

    mock(fn
      %{method: :put, url: "https://rabbitmq.example.com:5672/api/vhosts/foobar"} ->
        %Tesla.Env{status: 204}
    end)

    on_exit(fn ->
      Application.delete_env(:ex_rabbitmqadmin, ExRabbitMQAdmin.Client)
    end)

    :ok
  end

  test "get default client with configured middleware" do
    assert %Tesla.Client{
             pre: [
               {Tesla.Middleware.BaseUrl, :call, ["https://rabbitmq.example.com:5672"]},
               {Tesla.Middleware.Logger, :call, [[filter_headers: ["authorization"]]]},
               {Tesla.Middleware.JSON, :call, [[engine: Jason]]}
             ]
           } = Client.client()
  end

  test "can add basic auth to default client" do
    assert %Tesla.Client{
             pre: [
               {Tesla.Middleware.BasicAuth, :call,
                [[{:username, "username"}, {:password, "password"}]]}
               | _rest
             ]
           } =
             Client.client()
             |> Client.add_basic_auth_middleware(username: "username", password: "password")
  end

  test "can add basic auth with credentials from config to default client" do
    assert %Tesla.Client{
             pre: [
               {Tesla.Middleware.BasicAuth, :call, [[{:username, "guest"}, {:password, "guest"}]]}
               | _rest
             ]
           } = Client.client() |> Client.add_basic_auth_middleware()
  end

  test "can add bearer auth with token to default client" do
    assert %Tesla.Client{
             pre: [
               {Tesla.Middleware.BearerAuth, :call, [[token: "this is my token"]]}
               | _rest
             ]
           } = Client.client() |> Client.add_bearer_auth_middleware(token: "this is my token")
  end

  test "PUT a new vhost" do
    params = %{
      "name" => "foobar",
      "description" => "a new vhost",
      "tags" => ""
    }

    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client()
             |> Client.put_vhost(params)
  end
end
