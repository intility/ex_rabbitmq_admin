defmodule ExRabbitMQAdmin.Auth do
  @moduledoc """
  This module contains functions for RabbitMQ authentication and OAuth2 configuration.
  """

  @doc """
  Get OAuth2 configuration details.
  """
  @spec get_auth(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def get_auth(client), do: Tesla.get(client, "/api/auth")

  @doc """
  List authentication attempts on a node.
  """
  @spec list_auth_attempts(client :: Tesla.Client.t(), node :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_auth_attempts(client, node), do: Tesla.get(client, "/api/auth/attempts/#{node}")

  @doc """
  List authentication attempts by remote address and username on a node.
  """
  @spec list_auth_attempts_by_source(client :: Tesla.Client.t(), node :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_auth_attempts_by_source(client, node),
    do: Tesla.get(client, "/api/auth/attempts/#{node}/source")
end
