defmodule ExRabbitMQAdmin.FederationLink do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ federation link status. Requires the rabbitmq_federation plugin.
  """

  @api_namespace "/api/federation-links"

  @doc """
  List status of all federation links.
  """
  @spec list_federation_links(client :: Tesla.Client.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_federation_links(client), do: Tesla.get(client, @api_namespace)

  @doc """
  List federation links in a vhost.
  """
  @spec list_vhost_federation_links(client :: Tesla.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_vhost_federation_links(client, vhost),
    do: Tesla.get(client, "#{@api_namespace}/#{vhost}")
end
