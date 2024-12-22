defmodule ExRabbitMQAdmin.Node do
  @moduledoc """
  Get information about nodes in the RabbitMQ cluster.
  """
  import ExRabbitMQAdmin.Options,
    only: [
      get_node_definition: 0,
      format_error: 1
    ]

  @api_namespace "/api/nodes"

  @doc """
  Get a list of nodes in the RabbitMQ cluster.
  """
  @spec list_nodes(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_nodes(client), do: Tesla.get(client, @api_namespace)

  @doc """
  Get information about a specific node in the RabbitMQ cluster.
  """
  @spec get_node(client :: Tesla.Client.t(), node :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_node(client, node, opts \\ []) do
    case NimbleOptions.validate(opts, get_node_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, opts} ->
        client
        |> ExRabbitMQAdmin.add_query_middleware(opts)
        |> Tesla.get("#{@api_namespace}/#{node}")
    end
  end
end
