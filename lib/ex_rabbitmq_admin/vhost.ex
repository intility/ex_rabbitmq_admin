defmodule ExRabbitMQAdmin.Vhost do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ virtual hosts.
  """
  import ExRabbitMQAdmin.Options,
    only: [
      pagination_definition: 0,
      put_vhost_definition: 0,
      put_vhost_permissions: 0,
      format_error: 1
    ]

  @api_namespace "/api/vhosts"

  @doc """
  List all virtual hosts running on the RabbitMQ cluster.

  ### Params

    * `client` - Tesla client used to perform the request.
  """
  @spec list_vhosts(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()}
  def list_vhosts(client), do: client |> Tesla.get(@api_namespace)

  @doc """
  List all open open connections in a specific virtual host.
  Optionally pass pagination parameters to filter connections.

  ### Params

    * `client` - Tesla client used to perform the request.
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
        |> Tesla.get("#{@api_namespace}/#{name}/connections")
    end
  end

  @doc """
  List all open channels for a specific virtual host.
  Optionally pass pagination parameters to filter channels.

  ### Params

    * `client` - Tesla client used to perform the request.
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
        |> Tesla.get("#{@api_namespace}/#{name}/connections")
    end
  end

  @doc """
  List all permissions for a specific virtual host.

  ### Params

  * `client` - Tesla client used to perform the request.
  * `name` - type: `string`, The name of the vhost to list permissions for.
  """
  @spec list_vhost_permissions(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_permissions(client, name),
    do: client |> Tesla.get("#{@api_namespace}/#{name}/permissions")

  @doc """
  Set permissions for a user on a specific virtual host.
  RabbitMQ permissions are defined as triples of regular expressions.

  Please consult the
  [official documentation](https://www.rabbitmq.com/access-control.html#authorisation)
  for more details.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `name` - type: `string`, The name of the vhost to assign permissions for.
    * `user` - type: `string`, The username to assign permissions for.
    #{NimbleOptions.docs(put_vhost_permissions())}
  """
  def put_vhost_permissions(client, name, user, opts \\ []) do
    case NimbleOptions.validate(opts, put_vhost_permissions()) do
      {:ok, opts} ->
        client |> Tesla.put("/api/permissions/#{name}/#{user}", Enum.into(opts, %{}))

      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end

  @doc """
  List all topic permissions for a specific virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
  """
  @spec list_vhost_topic_permissions(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_topic_permissions(client, name),
    do: client |> Tesla.get("#{@api_namespace}/#{name}/topic-permissions")

  @doc """
  Get an individual virtual host by name.

  ### Params

    * `client` - Tesla client used to perform the request.
  """
  @spec get_vhost(client :: Telsa.Client.t(), name :: String.t()) :: {:ok, Tesla.Env.t()}
  def get_vhost(client, name) when is_binary(name),
    do: client |> Tesla.get("#{@api_namespace}/#{name}")

  @doc """
  Create a new virtual host with given name.

  ### Params

    * `client` - Tesla client used to perform the request.
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
        |> Tesla.put("#{@api_namespace}/#{name}", Enum.into(opts, %{}))
    end
  end

  @doc """
  Delete a specific virtual host by name.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `name` - type: `string`, The name of the virtual host that should be deleted.
  """
  @spec delete_vhost(client :: Tesla.Client.t(), name :: String.t()) :: {:ok, Tesla.Env.t()}
  def delete_vhost(client, name), do: client |> Tesla.delete("#{@api_namespace}/#{name}")

  @doc """
  Start a specific virtual host on given node.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `name` - type: `string`, The name of the virtual host that should be started.
    * `node` - type: `string`, The name of the node that the virtual host should be started on.
  """
  @spec start_vhost(client :: Tesla.Client.t(), name :: String.t(), node :: String.t()) ::
          {:ok, Tesla.Env.t()}
  def start_vhost(client, name, node),
    do: client |> Tesla.post("#{@api_namespace}/#{name}/start/#{node}", %{})
end
