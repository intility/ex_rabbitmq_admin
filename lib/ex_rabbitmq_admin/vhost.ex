defmodule ExRabbitMQAdmin.Vhost do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ Vhosts.
  """
  import ExRabbitMQAdmin.Options,
    only: [
      pagination_definition: 0,
      put_vhost_definition: 0,
      format_error: 1
    ]

  @doc """
  List all virtual hosts running on the RabbitMQ cluster.
  """
  @spec list_vhosts(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()}
  def list_vhosts(client), do: client |> Tesla.get("/api/vhosts")

  @doc """
  List all open open connections in a specific virtual host.
  Optionally pass pagination parameters to filter connections.

  ### Params

    * `name` - type: `string`, required: `true`
    #{NimbleOptions.docs(pagination_definition())}
  """
  @spec list_vhost_connections(
          client :: Tesla.Client.t(),
          name :: String.t(),
          opts :: Keyword.t()
        ) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_connections(client, name, opts \\ []) do
    case NimbleOptions.validate(opts, pagination_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, opts} ->
        client
        |> ExRabbitMQAdmin.add_query_middleware(opts)
        |> Tesla.get("/api/vhosts/#{name}/connections")
    end
  end

  @doc """
  List all open channels for a specific virtual host.
  Optionally pass pagination parameters to filter channels.

  ### Params

    * `name` - type: `string`, required: `true`
    #{NimbleOptions.docs(pagination_definition())}
  """
  @spec list_vhost_channels(client :: Tesla.Client.t(), name :: String.t(), opts :: Keyword.t()) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_channels(client, name, opts \\ []) do
    case NimbleOptions.validate(opts, pagination_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, opts} ->
        client
        |> ExRabbitMQAdmin.add_query_middleware(opts)
        |> Tesla.get("/api/vhosts/#{name}/connections")
    end
  end

  @doc """
  List all permissions for a specific virtual host.
  """
  @spec list_vhost_permissions(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_permissions(client, name) do
    client |> Tesla.get("/api/vhosts/#{name}/permissions")
  end

  @doc """
  List all topic permissions for a specific virtual host.
  """
  @spec list_vhost_topic_permissions(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_topic_permissions(client, name) do
    client |> Tesla.get("/api/vhosts/#{name}/topic-permissions")
  end

  @doc """
  Get an individual virtual host by name.
  """
  @spec get_vhost(client :: Telsa.Client.t(), name :: String.t()) :: {:ok, Tesla.Env.t()}
  def get_vhost(client, name) when is_binary(name), do: client |> Tesla.get("/api/vhosts/#{name}")

  @doc """
  Create a new virtual host with given name.

  ### Params

    * `name` - type: `string`, required: `true`
    #{NimbleOptions.docs(put_vhost_definition())}
  """
  @spec put_vhost(client :: Telsa.Client.t(), name :: String.t(), opts :: Keyword.t()) ::
          {:ok, Tesla.Env.t()}
  def put_vhost(client, name, opts \\ []) do
    case NimbleOptions.validate(opts, put_vhost_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, opts} ->
        client
        |> Tesla.put("/api/vhosts/#{name}", Enum.into(opts, %{}))
    end
  end

  @doc """
  Delete a specific virtual host by name.
  """
  @spec delete_vhost(client :: Tesla.Client.t(), name :: String.t()) :: {:ok, Tesla.Env.t()}
  def delete_vhost(client, name), do: client |> Tesla.delete("/api/vhosts/#{name}")

  @doc """
  Start a specific virtual host on given node.
  """
  @spec start_vhost(client :: Tesla.Client.t(), name :: String.t(), node :: String.t()) ::
          {:ok, Tesla.Env.t()}
  def start_vhost(client, name, node) do
    client |> Tesla.post("/api/vhosts/#{name}/start/#{node}", %{})
  end
end
