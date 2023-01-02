defmodule ExRabbitMQAdmin.QueueTest do
  use ExRabbitMQAdmin.TestCase, async: true
  import ExUnit.CaptureLog

  alias ExRabbitMQAdmin.Queue

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/queues"} ->
        %Tesla.Env{status: 200, body: read_json("list_queues.json")}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/queues/my-vhost"} ->
        %Tesla.Env{status: 200, body: read_json("list_queues.json")}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/queues/unknown-vhost"} ->
        %Tesla.Env{status: 404, body: %{"error" => "Object Not Found", "reason" => "Not Found"}}

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/queues/my-vhost/my-queue-1"} ->
        %Tesla.Env{status: 200, body: read_json("get_queue.json")}
    end)
  end

  test "can list queues" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: [
                %{"name" => "my-queue-1"},
                %{"name" => "my-queue-2"}
              ]
            }} = Client.client() |> Queue.list_queues()

    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> Queue.list_queues(page: 1, page_size: 2)

    assert_raise ArgumentError,
                 "unknown options [:invalid_opt], valid options are: [:page, :page_size, :name, :use_regex]",
                 fn ->
                   Client.client() |> Queue.list_queues(invalid_opt: "should-raise")
                 end
  end

  test "can list queues by vhost" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: [
                %{"name" => "my-queue-1"},
                %{"name" => "my-queue-2"}
              ]
            }} = Client.client() |> Queue.list_vhost_queues("my-vhost")

    assert {:ok, %Tesla.Env{status: 200}} =
             Client.client() |> Queue.list_vhost_queues("my-vhost", page: 1, page_size: 2)

    assert_raise ArgumentError,
                 "unknown options [:invalid_opt], valid options are: [:page, :page_size, :name, :use_regex]",
                 fn ->
                   Client.client()
                   |> Queue.list_vhost_queues("my-vhost", invalid_opt: "should-raise")
                 end

    assert {:ok,
            %Tesla.Env{
              status: 404,
              body: %{"error" => "Object Not Found", "reason" => "Not Found"}
            }} = Client.client() |> Queue.list_vhost_queues("unknown-vhost")
  end

  test "can get a single queue on vhost by name" do
    assert {:ok, %Tesla.Env{status: 200, body: %{"name" => "my-queue-1", "vhost" => "my-vhost"}}} =
             Client.client() |> Queue.get_queue("my-vhost", "my-queue-1")
  end
end
