defmodule ExRabbitMQAdmin.Connection do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ connections.
  """

  @api_namespace "/api/connections"

  @doc """
  List all open connections.

  ### Params

    * `client` - Tesla client used to perform the request.
  """
  @spec list_connections(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_connections(client), do: client |> Tesla.get(@api_namespace)

  @doc """
  Get an individual connection by name.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `name` - type: `string`, The name of the connection to get.
  """
  @spec get_connection(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_connection(client, name), do: client |> Tesla.get("#{@api_namespace}/#{name}")

  @doc """
  Close a connection by name.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `name` - type: `string`, The name of the connection to close.
  """
  @spec delete_connection(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_connection(client, name), do: client |> Tesla.delete("#{@api_namespace}/#{name}")

  @doc """
  List all connections for a specific username.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `username` - type: `string`, The username to list connections for.
  """
  @spec list_user_connections(client :: Tesla.Client.t(), username :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_user_connections(client, username),
    do: client |> Tesla.get("#{@api_namespace}/username/#{username}")

  @doc """
  Close all connections for a specific username.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `username` - type: `string`, The username to close connections for.
  """
  @spec delete_user_connections(client :: Tesla.Client.t(), username :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_user_connections(client, username),
    do: client |> Tesla.delete("#{@api_namespace}/username/#{username}")

  @doc """
  List all channels for a specific connection.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `name` - type: `string`, The name of the connection to list channels for.
  """
  @spec list_connection_channels(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_connection_channels(client, name),
    do: client |> Tesla.get("#{@api_namespace}/#{name}/channels")
end
