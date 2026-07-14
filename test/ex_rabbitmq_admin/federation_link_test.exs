defmodule ExRabbitmqAdmin.FederationLinkTest do
  use ExRabbitMQAdmin.TestCase, async: true
  alias ExRabbitMQAdmin.FederationLink

  @vhost "my-vhost"

  setup do
    mock(fn
      %{method: :get, url: "https://rabbitmq.example.com:5672/api/federation-links"} ->
        %Tesla.Env{status: 200, body: []}

      %{
        method: :get,
        url: "https://rabbitmq.example.com:5672/api/federation-links/#{@vhost}"
      } ->
        %Tesla.Env{status: 200, body: []}
    end)
  end

  test "can list status of all federation links" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> FederationLink.list_federation_links()
  end

  test "can list federation links in a vhost" do
    assert {:ok, %Tesla.Env{status: 200, body: _body}} =
             Client.client() |> FederationLink.list_vhost_federation_links(@vhost)
  end
end
