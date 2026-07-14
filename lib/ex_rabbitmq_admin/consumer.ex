defmodule ExRabbitMQAdmin.Consumer do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ consumers.
  """

  @api_namespace "/api/consumers"

  @doc """
  List all consumers.
  """
  @spec list_consumers(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_consumers(client), do: Tesla.get(client, @api_namespace)

  @doc """
  List consumers in a specific vhost.
  """
  @spec list_vhost_consumers(client :: Tesla.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_vhost_consumers(client, vhost), do: Tesla.get(client, "#{@api_namespace}/#{vhost}")
end
