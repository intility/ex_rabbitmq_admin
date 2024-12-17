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
  @spec list_vhosts(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_vhosts(client), do: client |> Tesla.get(@api_namespace)

  @doc """
  List all open open connections in a specific virtual host.
  Optionally pass pagination parameters to filter connections.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    #{NimbleOptions.docs(pagination_definition())}
  """
  @spec list_vhost_connections(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          opts :: Keyword.t()
        ) ::
          {:ok, Tesla.Env.t()} | no_return()
  def list_vhost_connections(client, vhost, opts \\ []) do
    case NimbleOptions.validate(opts, pagination_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, opts} ->
        client
        |> ExRabbitMQAdmin.add_query_middleware(opts)
        |> Tesla.get("#{@api_namespace}/#{vhost}/connections")
    end
  end

  @doc """
  List all open channels for a specific virtual host.
  Optionally pass pagination parameters to filter channels.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    #{NimbleOptions.docs(pagination_definition())}
  """
  @spec list_vhost_channels(client :: Tesla.Client.t(), vhost :: String.t(), opts :: Keyword.t()) ::
          {:ok, Tesla.Env.t()} | no_return()
  def list_vhost_channels(client, vhost, opts \\ []) do
    case NimbleOptions.validate(opts, pagination_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, opts} ->
        client
        |> ExRabbitMQAdmin.add_query_middleware(opts)
        |> Tesla.get("#{@api_namespace}/#{vhost}/connections")
    end
  end

  @doc """
  List all permissions for a specific virtual host.

  ### Params

  * `client` - Tesla client used to perform the request.
  * `vhost` - type: `string`, The vhost of the vhost to list permissions for.
  """
  @spec list_vhost_permissions(client :: Tesla.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_vhost_permissions(client, vhost),
    do: client |> Tesla.get("#{@api_namespace}/#{vhost}/permissions")

  @doc """
  Set permissions for a user on a specific virtual host.
  RabbitMQ permissions are defined as triplets of regular expressions.

  Please consult the
  [official documentation](https://www.rabbitmq.com/access-control.html#authorisation)
  for more details.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, The vhost of the vhost to assign permissions for.
    * `user` - type: `string`, The username to assign permissions for.
    #{NimbleOptions.docs(put_vhost_permissions())}
  """
  @spec put_vhost_permissions(
          client :: Telsa.Client.t(),
          vhost :: String.t(),
          user :: String.t(),
          opts :: Keyword.t()
        ) :: {:ok, Tesla.Env.t()} | no_return()
  def put_vhost_permissions(client, vhost, user, opts \\ []) do
    case NimbleOptions.validate(opts, put_vhost_permissions()) do
      {:ok, opts} ->
        client |> Tesla.put("/api/permissions/#{vhost}/#{user}", Enum.into(opts, %{}))

      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end

  @doc """
  List all topic permissions for a specific virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
  """
  @spec list_vhost_topic_permissions(client :: Tesla.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t() | {:error, term()}}
  def list_vhost_topic_permissions(client, vhost),
    do: client |> Tesla.get("#{@api_namespace}/#{vhost}/topic-permissions")

  @doc """
  Get an individual virtual host by vhost.

  ### Params

    * `client` - Tesla client used to perform the request.
  """
  @spec get_vhost(client :: Telsa.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_vhost(client, vhost) when is_binary(vhost),
    do: client |> Tesla.get("#{@api_namespace}/#{vhost}")

  @doc """
  Create a new virtual host with given vhost.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    #{NimbleOptions.docs(put_vhost_definition())}
  """
  @spec put_vhost(client :: Telsa.Client.t(), vhost :: String.t(), opts :: Keyword.t()) ::
          {:ok, Tesla.Env.t()} | no_return()
  def put_vhost(client, vhost, opts \\ []) do
    case NimbleOptions.validate(opts, put_vhost_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, opts} ->
        client
        |> Tesla.put("#{@api_namespace}/#{vhost}", Enum.into(opts, %{}))
    end
  end

  @doc """
  Delete a specific virtual host by vhost.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, The vhost of the virtual host that should be deleted.
  """
  @spec delete_vhost(client :: Tesla.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_vhost(client, vhost), do: client |> Tesla.delete("#{@api_namespace}/#{vhost}")

  @doc """
  Start a specific virtual host on given node.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, The vhost of the virtual host that should be started.
    * `node` - type: `string`, The vhost of the node that the virtual host should be started on.
  """
  @spec start_vhost(client :: Tesla.Client.t(), vhost :: String.t(), node :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def start_vhost(client, vhost, node),
    do: client |> Tesla.post("#{@api_namespace}/#{vhost}/start/#{node}", %{})
end
