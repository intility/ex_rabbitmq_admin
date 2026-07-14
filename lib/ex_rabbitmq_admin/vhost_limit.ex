defmodule ExRabbitMQAdmin.VhostLimit do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ per-vhost limits.
  """

  @api_namespace "/api/vhost-limits"

  @doc """
  List per-vhost limits for all vhosts.
  """
  @spec list_vhost_limits(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_vhost_limits(client), do: Tesla.get(client, @api_namespace)

  @doc """
  List limits for a specific vhost.
  """
  @spec get_vhost_limits(client :: Tesla.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_vhost_limits(client, vhost), do: Tesla.get(client, "#{@api_namespace}/#{vhost}")

  @doc """
  Get a specific limit for a vhost.
  """
  @spec get_vhost_limit(client :: Tesla.Client.t(), vhost :: String.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_vhost_limit(client, vhost, name),
    do: Tesla.get(client, "#{@api_namespace}/#{vhost}/#{name}")

  @doc """
  Set a limit for a vhost.
  """
  @spec put_vhost_limit(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          name :: String.t(),
          value :: integer()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def put_vhost_limit(client, vhost, name, value) when is_integer(value),
    do: Tesla.put(client, "#{@api_namespace}/#{vhost}/#{name}", %{"value" => value})

  @doc """
  Delete a limit for a vhost.
  """
  @spec delete_vhost_limit(client :: Tesla.Client.t(), vhost :: String.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_vhost_limit(client, vhost, name),
    do: Tesla.delete(client, "#{@api_namespace}/#{vhost}/#{name}")
end
