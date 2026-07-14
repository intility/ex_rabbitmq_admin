defmodule ExRabbitMQAdmin.TopicPermission do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ topic permissions.
  """

  import ExRabbitMQAdmin.Options,
    only: [put_topic_permission_definition: 0, format_error: 1]

  @api_namespace "/api/topic-permissions"

  @doc """
  Get a list of topic permissions for all users.
  """
  @spec list_topic_permissions(client :: Tesla.Client.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_topic_permissions(client), do: Tesla.get(client, @api_namespace)

  @doc """
  Get topic permissions for a user on a specific vhost.
  """
  @spec get_topic_permission(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          user :: String.t()
        ) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_topic_permission(client, vhost, user),
    do: Tesla.get(client, "#{@api_namespace}/#{vhost}/#{user}")

  @doc """
  Set topic permissions for a user on a specific vhost.

  ## Options

  #{NimbleOptions.docs(put_topic_permission_definition())}
  """
  @spec put_topic_permission(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          user :: String.t(),
          opts :: Keyword.t()
        ) ::
          {:ok, Tesla.Env.t()} | no_return()
  def put_topic_permission(client, vhost, user, opts \\ []) do
    case NimbleOptions.validate(opts, put_topic_permission_definition()) do
      {:ok, opts} ->
        Tesla.put(client, "#{@api_namespace}/#{vhost}/#{user}", Enum.into(opts, %{}))

      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end

  @doc """
  Delete topic permissions for a user on a specific vhost.
  """
  @spec delete_topic_permission(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          user :: String.t()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_topic_permission(client, vhost, user),
    do: Tesla.delete(client, "#{@api_namespace}/#{vhost}/#{user}")
end
