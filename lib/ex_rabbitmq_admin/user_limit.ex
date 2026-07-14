defmodule ExRabbitMQAdmin.UserLimit do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ per-user limits.
  """

  @api_namespace "/api/user-limits"

  @doc """
  List per-user limits for all users.
  """
  @spec list_user_limits(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_user_limits(client), do: Tesla.get(client, @api_namespace)

  @doc """
  List limits for a specific user.
  """
  @spec get_user_limits(client :: Tesla.Client.t(), user :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_user_limits(client, user), do: Tesla.get(client, "#{@api_namespace}/#{user}")

  @doc """
  Get a specific limit for a user.
  """
  @spec get_user_limit(client :: Tesla.Client.t(), user :: String.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_user_limit(client, user, name),
    do: Tesla.get(client, "#{@api_namespace}/#{user}/#{name}")

  @doc """
  Set a limit for a user.
  """
  @spec put_user_limit(
          client :: Tesla.Client.t(),
          user :: String.t(),
          name :: String.t(),
          value :: integer()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def put_user_limit(client, user, name, value) when is_integer(value),
    do: Tesla.put(client, "#{@api_namespace}/#{user}/#{name}", %{"value" => value})

  @doc """
  Delete a limit for a user.
  """
  @spec delete_user_limit(client :: Tesla.Client.t(), user :: String.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_user_limit(client, user, name),
    do: Tesla.delete(client, "#{@api_namespace}/#{user}/#{name}")
end
