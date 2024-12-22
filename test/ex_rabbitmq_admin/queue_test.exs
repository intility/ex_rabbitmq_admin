defmodule ExRabbitMQAdmin.QueueTest do
  use ExRabbitMQAdmin.TestCase, async: true
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

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/queues/my-vhost/my-queue-1/bindings"
      } ->
        %Tesla.Env{status: 200, body: read_json("list_queue_bindings.json")}

      %{
        method: :put,
        url: "https://rabbitmq.example.com:5672/api/queues/my-vhost/brand-new-queue"
      } ->
        %Tesla.Env{status: 201}

      %{method: :delete, url: "https://rabbitmq.example.com:5672/api/queues/my-vhost/delete-me"} ->
        %Tesla.Env{status: 204}

      %{
        method: :delete,
        url: "https://rabbitmq.example.com:5672/api/queues/my-vhost/my-queue/contents"
      } ->
        %Tesla.Env{status: 204}

      %{
        method: :post,
        url: "https://rabbitmq.example.com:5672/api/queues/my-vhost/my-queue/actions"
      } ->
        %Tesla.Env{status: 201}

      %{
        method: :post,
        url: "https://rabbitmq.example.com:5672/api/queues/my-vhost/my-queue/get"
      } ->
        %Tesla.Env{status: 200, body: read_json("get_queue_messages.json")}
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

  test "can list queue bindings" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: [
                %{"source" => "", "vhost" => "my-vhost", "destination" => "my-queue-1"},
                %{"source" => "amq.direct", "vhost" => "my-vhost", "destination" => "my-queue-1"}
              ]
            }} = Client.client() |> Queue.list_queue_bindings("my-vhost", "my-queue-1")
  end

  test "can get a single queue on vhost by name" do
    assert {:ok, %Tesla.Env{status: 200, body: %{"name" => "my-queue-1", "vhost" => "my-vhost"}}} =
             Client.client() |> Queue.get_queue("my-vhost", "my-queue-1")
  end

  test "can create a new queue" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client() |> Queue.put_queue("my-vhost", "brand-new-queue")

    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client()
             |> Queue.put_queue("my-vhost", "brand-new-queue",
               auto_delete: true,
               durable: false,
               node: "rabbit1@rabbitmq",
               arguments: %{"x-queue-type" => "quorum"}
             )

    assert_raise ArgumentError,
                 "unknown options [:invalid_opt], valid options are: [:auto_delete, :durable, :node, :arguments]",
                 fn ->
                   Client.client()
                   |> Queue.put_queue("my-vhost", "my-queue", invalid_opt: "should-raise")
                 end

    assert_raise ArgumentError,
                 "invalid value for :arguments option: expected map, got: \"not-a-map\"",
                 fn ->
                   Client.client()
                   |> Queue.put_queue("my-vhost", "my-queue", arguments: "not-a-map")
                 end
  end

  test "can delete a queue" do
    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client() |> Queue.delete_queue("my-vhost", "delete-me")

    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client() |> Queue.delete_queue("my-vhost", "delete-me", if_unused: true)

    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client() |> Queue.delete_queue("my-vhost", "delete-me", if_empty: true)

    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client()
             |> Queue.delete_queue("my-vhost", "delete-me", if_unused: true, if_empty: false)

    assert_raise ArgumentError,
                 "unknown options [:invalid_opt], valid options are: [:if_empty, :if_unused]",
                 fn ->
                   Client.client()
                   |> Queue.delete_queue("my-vhost", "delete-me", invalid_opt: "should-raise")
                 end
  end

  test "can purge queue messages" do
    assert {:ok, %Tesla.Env{status: 204}} =
             Client.client() |> Queue.purge_queue("my-vhost", "my-queue")
  end

  test "can perform a 'sync' queue action" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client() |> Queue.perform_queue_action("my-vhost", "my-queue", :sync)
  end

  test "can perform a 'cancel sync' queue action" do
    assert {:ok, %Tesla.Env{status: 201}} =
             Client.client() |> Queue.perform_queue_action("my-vhost", "my-queue", :cancel_sync)
  end

  test "can receive messages from a queue" do
    assert {:ok,
            %Tesla.Env{
              status: 200,
              body: [
                %{
                  "exchange" => "amq.direct",
                  "routing_key" => "my-queue-routing-key",
                  "payload" => "{\"message\":\"Hello, world!\"}"
                }
              ]
            }} =
             Client.client()
             |> Queue.receive_queue_messages("my-vhost", "my-queue", ackmode: :ack_requeue_true)

    assert_raise ArgumentError,
                 "unknown options [:invalid_opt], valid options are: [:count, :ackmode, :encoding, :truncate]",
                 fn ->
                   Client.client()
                   |> Queue.receive_queue_messages("my-vhost", "my-queue",
                     invalid_opt: "should-raise"
                   )
                 end
  end
end
