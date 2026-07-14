defmodule ExRabbitMQAdmin.Definition do
  @moduledoc """
  Functions for interacting with RabbitMQ server and virtual host definitions.
  """

  @api_namespace "/api/definitions"

  @doc """
  List all server definitions - exchanges, queues, bindings, users,
  virtual hosts, permissions, topic permissions, and parameters.
  """
  @spec list_definitions(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_definitions(client), do: Tesla.get(client, @api_namespace)

  @doc """
  List all definitions for a specific virtual host.
  """
  @spec list_vhost_definitions(client :: Tesla.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_vhost_definitions(client, vhost), do: Tesla.get(client, "#{@api_namespace}/#{vhost}")

  @doc """
  Upload and merge server definitions. Existing definitions will be merged
  with the uploaded ones.
  """
  @spec upload_definitions(client :: Tesla.Client.t(), definitions :: map()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def upload_definitions(client, definitions) when is_map(definitions),
    do: Tesla.post(client, @api_namespace, definitions)

  @doc """
  Upload definitions for a specific virtual host.
  """
  @spec upload_vhost_definitions(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          definitions :: map()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def upload_vhost_definitions(client, vhost, definitions) when is_map(definitions),
    do: Tesla.post(client, "#{@api_namespace}/#{vhost}", definitions)
end
