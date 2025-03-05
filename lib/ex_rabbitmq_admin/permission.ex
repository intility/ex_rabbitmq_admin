defmodule ExRabbitMQAdmin.Permission do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ permissions.
  """
  require Logger

  import ExRabbitMQAdmin.Options,
    only: [put_vhost_permissions: 0, format_error: 1]

  @api_namespace "/api/permissions"

  @doc """
  Get a list of permissions for all users.
  """
  @spec get_permissions(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def get_permissions(client), do: Tesla.get(client, @api_namespace)

  @doc """
  Get list of permissions for a user on a specific vhost.
  """
  @spec get_vhost_user_permissions(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          user :: String.t()
        ) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_vhost_user_permissions(client, vhost, user),
    do: Tesla.get(client, "#{@api_namespace}/#{vhost}/#{user}")

  @doc """
  Set permissions for a user on a specific vhost.
  """
  @spec put_vhost_user_permissions(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          user :: String.t(),
          opts :: Keyword.t()
        ) ::
          {:ok, Tesla.Env.t()} | no_return()
  def put_vhost_user_permissions(client, vhost, user, opts) do
    case NimbleOptions.validate(opts, put_vhost_permissions()) do
      {:ok, opts} ->
        Tesla.put(client, "#{@api_namespace}/#{vhost}/#{user}", Enum.into(opts, %{}))

      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end

  @doc """
  Delete permissions for a user on a specific vhost.
  """
  @spec delete_vhost_user_permissions(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          user :: String.t()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_vhost_user_permissions(client, vhost, user),
    do: Tesla.delete(client, "#{@api_namespace}/#{vhost}/#{user}")
end
