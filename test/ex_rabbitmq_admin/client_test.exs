defmodule ExRabbitMQAdminTest.Client do
  use ExRabbitMQAdmin.TestCase, async: true

  setup do
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

  test "can add query params to default client" do
    assert %Tesla.Client{
             pre: [
               {Tesla.Middleware.Query, :call, [[baz: "qux"]]},
               {Tesla.Middleware.Query, :call, [[foo: "bar"]]}
               | _rest
             ]
           } =
             Client.client()
             |> Client.add_query_middleware(:foo, "bar")
             |> Client.add_query_middleware(:baz, "qux")

    assert %Tesla.Client{
             pre: [
               {Tesla.Middleware.Query, :call, [[foo: "bar", baz: "qux"]]}
               | _rest
             ]
           } =
             Client.client()
             |> Client.add_query_middleware(foo: "bar", baz: "qux")
  end
end
