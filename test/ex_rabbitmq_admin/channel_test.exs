defmodule ExRabbitmqAdmin.ChannelTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.Channel

  @channel "127.0.0.1:5672 -> 127.0.0.1:49152 (1)"

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/channels"} ->
        %Tesla.Env{
          status: 200,
          body: [
            %{
              "name" => @channel,
              "number" => 1,
              "state" => "running",
              "vhost" => "/"
            }
          ]
        }

      %{method: :get, url: "https://rabbitmq.example.com:5672/api/channels/#{@channel}"} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "name" => @channel,
            "number" => 1,
            "state" => "running",
            "vhost" => "/"
          }
        }
    end)
  end

  test "can list all open channels" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Channel.list_channels()
  end

  test "can get individual channel details" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> Channel.get_channel(@channel)
  end
end
