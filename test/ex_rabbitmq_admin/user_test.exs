defmodule ExRabbitMQAdmin.UserTest do
  use ExRabbitMQAdmin.TestCase, async: true
  import ExUnit.CaptureLog

  alias ExRabbitMQAdmin.User

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/users"} ->
        %Tesla.Env{status: 200, body: read_json("list_users.json")}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/users/testuser"} ->
        %Tesla.Env{status: 200, body: read_json("get_user.json")}

      %{method: :put, url: "https://rabbitmq.example.com:5672/api/users/testuser"} ->
        %Tesla.Env{status: 201}

      %{method: :delete, url: "https://rabbitmq.example.com:5672/api/users/testuser"} ->
        %Tesla.Env{status: 204}

      %{method: :post, url: "https://rabbitmq.example.com:5672/api/users/bulk-delete"} ->
        %Tesla.Env{status: 204}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/users/without-permissions"} ->
        %Tesla.Env{status: 200, body: read_json("list_users.json")}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/users/testuser/permissions"} ->
        %Tesla.Env{status: 200}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/users/testuser/topic-permissions"
      } ->
        %Tesla.Env{status: 200}
    end)
  end

  test "can list users" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: [
                %{"name" => "guest"},
                %{"name" => "testuser"}
              ]
            }} = Client.client() |> User.list_users()
  end

  test "can get a single user by name" do
    assert {:ok, %Tesla.Env{status: 200, body: %{"name" => "testuser"}}} =
             Client.client() |> User.get_user("testuser")
  end

  test "can create a new user" do
    {result, log} =
      with_log(fn ->
        Client.client()
        |> User.put_user("testuser", password: "supersecret", tags: "moderator")
      end)

    assert {:ok, %Tesla.Env{status: 201}} = result
    assert log =~ "%{hashing_algorithm: \"rabbit_password_hashing_sha512\", password_hash:"

    assert_raise ArgumentError,
                 "required :tags option not found, received options: [:password]",
                 fn ->
                   Client.client()
                   |> User.put_user("testuser", password: "supersecret")
                 end

    assert_raise ArgumentError,
                 "required :password option not found, received options: [:tags]",
                 fn ->
                   Client.client()
                   |> User.put_user("testuser", tags: "moderator")
                 end

    assert_raise ArgumentError,
                 "unknown options [:invalid_tag], valid options are: [:password, :tags]",
                 fn ->
                   Client.client()
                   |> User.put_user("testuser", invalid_tag: true)
                 end
  end

  test "can delete a user by name" do
    assert {:ok, %Tesla.Env{status: 204}} = Client.client() |> User.delete_user("testuser")
  end

  test "can bulk delete users" do
    {result, log} =
      with_log(fn ->
        Client.client() |> User.bulk_delete_users(["user1", "user2"])
      end)

    assert assert {:ok, %Tesla.Env{status: 204}} = result
    assert log =~ "%{\"users\" => [\"user1\", \"user2\"]}"
  end

  test "can list users without permissions" do
    assert {:ok, %Tesla.Env{status: 200, body: [%{"name" => "guest"} | _]}} =
             Client.client() |> User.list_users_without_permissions()
  end

  test "can get user permissions" do
    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> User.get_user_permissions("testuser")
  end

  test "can get user topic permisssions" do
    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> User.get_user_topic_permissions("testuser")
  end
end
