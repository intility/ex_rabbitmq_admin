defmodule ExRabbitMQAdmin.Definition do
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
end
