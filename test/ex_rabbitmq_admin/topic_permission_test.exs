defmodule ExRabbitmqAdmin.TopicPermissionTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.TopicPermission

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/topic-permissions"} ->
        %Tesla.Env{
          status: 200,
          body: [
            %{
              "user" => "testuser",
              "vhost" => "my-vhost",
              "exchange" => "amq.topic",
              "write" => ".*",
              "read" => ".*"
            }
          ]
        }

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/topic-permissions/my-vhost/testuser"
      } ->
        %Tesla.Env{
          status: 200,
          body: %{
            "user" => "testuser",
            "vhost" => "my-vhost",
            "exchange" => "amq.topic",
            "write" => ".*",
            "read" => ".*"
          }
        }

      %{
        method: :put,
        url: "https://rabbitmq.example.com:5672/api/topic-permissions/my-vhost/testuser"
      } ->
        %Tesla.Env{status: 201}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/topic-permissions/my-vhost/testuser"
      } ->
        %Tesla.Env{status: 204, body: ""}
    end)
  end

  test "can get a list of topic permissions for all users" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> TopicPermission.list_topic_permissions()
  end

  test "can get topic permissions for a user on a specific vhost" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> TopicPermission.get_topic_permission("my-vhost", "testuser")
  end

  test "can set topic permissions for a user on a specific vhost" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client()
             |> TopicPermission.put_topic_permission("my-vhost", "testuser",
               exchange: "amq.topic",
               write: ".*",
               read: ".*"
             )
  end

  test "raises ArgumentError when opts are invalid" do
    assert_raise ArgumentError, fn ->
      Client.client()
      |> TopicPermission.put_topic_permission("my-vhost", "testuser",
        exchange: :not_a_string,
        write: ".*",
        read: ".*"
      )
    end
  end

  test "can delete topic permissions for a user on a specific vhost" do
    assert {:ok, %Tesla.Env{status: 204, body: ""}} =
             Client.client() |> TopicPermission.delete_topic_permission("my-vhost", "testuser")
  end
end
