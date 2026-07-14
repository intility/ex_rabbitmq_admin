defmodule ExRabbitMQAdmin.Channel do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ channels.
  """

  @api_namespace "/api/channels"

  @doc """
  List all open channels.
  """
  @spec list_channels(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_channels(client), do: Tesla.get(client, @api_namespace)

  @doc """
  Get details of an individual channel.
  """
  @spec get_channel(client :: Tesla.Client.t(), channel :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_channel(client, channel), do: Tesla.get(client, "#{@api_namespace}/#{channel}")
end
