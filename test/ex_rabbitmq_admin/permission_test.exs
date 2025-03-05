defmodule ExRabbitmqAdmin.PermissionTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Permission

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/permissions"} ->
        %Tesla.Env{status: 200, body: read_json("get_permissions.json")}

      %{method: :put, url: "https://rabbitmq.example.com:5672/api/permissions/my-vhost/testuser"} ->
        %Tesla.Env{status: 201}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/permissions/my-vhost/testuser"
      } ->
        %Tesla.Env{status: 204, body: ""}
    end)
  end

  test "can get a list of permissions for all users" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Permission.get_permissions()
  end

  test "can set permissions for a user on a specific vhost" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client()
             |> Permission.put_vhost_user_permissions("my-vhost", "testuser",
               configure: ".*",
               write: ".*",
               read: ".*"
             )
  end

  test "can delete permissions for a user on a specific vhost" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> Permission.delete_vhost_user_permissions("my-vhost", "testuser")
  end
end
