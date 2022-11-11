defmodule ExRabbitMQAdmin.VHostTest do
  use ExRabbitMQAdmin.TestCase, async: true

  alias ExRabbitMQAdmin.VHost

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/vhosts"} ->
        %Tesla.Env{status: 200, body: read_json("list_vhosts.json")}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/vhosts/my-vhost"} ->
        %Tesla.Env{status: 200, body: read_json("get_vhost.json")}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/vhosts/my-vhost/permissions"} ->
        %Tesla.Env{status: 200, body: read_json("get_vhost_permissions.json")}

      %{method: :put, url: "https://rabbitmq.example.com:5672/api/vhosts/my-vhost"} ->
        %Tesla.Env{status: 204}
    end)
  end

  test "can list vhosts" do
    assert {:ok, %Tesla.Env{status: 200, body: [%{"name" => "/"}, %{"name" => "my-vhost"}]}} =
             Client.client() |> VHost.list_vhosts()
  end

  test "can list vhost permissions" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: [
                %{
                  "configure" => ".*",
                  "read" => ".*",
                  "user" => "guest",
                  "vhost" => "my-vhost",
                  "write" => ".*"
                }
              ]
            }} = Client.client() |> VHost.list_vhost_permissions("my-vhost")
  end

  test "can get a single vhost by name" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: %{
                "cluster_state" => %{"rabbit@rabbitmq" => "running"},
                "default_queue_type" => "undefined",
                "description" => "a vhost for myself",
                "metadata" => %{
                  "description" => "a vhost for myself",
                  "tags" => ["personal", "other-tag"]
                },
                "name" => "my-vhost",
                "tags" => ["personal", "other-tag"],
                "tracing" => false
              }
            }} = Client.client() |> VHost.get_vhost("my-vhost")
  end

  test "can put a new vhost" do
    params = %{
      "name" => "my-vhost",
      "description" => "a new vhost",
      "tags" => ""
    }

    assert {:ok, %Tesla.Env{status: 204}} = Client.client() |> VHost.put_vhost(params)
  end
end
