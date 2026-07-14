defmodule ExRabbitmqAdmin.ConsumerTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Consumer

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/consumers"} ->
        %Tesla.Env{
          status: 200,
          body: [
            %{
              "consumer_tag" => "ctag1",
              "queue" => %{"name" => "my-queue", "vhost" => "my-vhost"}
            }
          ]
        }

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/consumers/my-vhost"} ->
        %Tesla.Env{
          status: 200,
          body: [
            %{
              "consumer_tag" => "ctag1",
              "queue" => %{"name" => "my-queue", "vhost" => "my-vhost"}
            }
          ]
        }
    end)
  end

  test "can list all consumers" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Consumer.list_consumers()
  end

  test "can list consumers in a specific vhost" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Consumer.list_vhost_consumers("my-vhost")
  end
end
