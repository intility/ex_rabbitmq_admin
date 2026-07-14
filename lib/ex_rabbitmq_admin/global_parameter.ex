defmodule ExRabbitMQAdmin.GlobalParameter do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ global parameters.
  """

  @api_namespace "/api/global-parameters"

  @doc """
  Get a list of all global parameters.
  """
  @spec list_global_parameters(client :: Tesla.Client.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_global_parameters(client), do: Tesla.get(client, @api_namespace)

  @doc """
  Get a specific global parameter.
  """
  @spec get_global_parameter(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_global_parameter(client, name), do: Tesla.get(client, "#{@api_namespace}/#{name}")

  @doc """
  Set a specific global parameter.
  """
  @spec put_global_parameter(client :: Tesla.Client.t(), name :: String.t(), value :: term()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def put_global_parameter(client, name, value),
    do: Tesla.put(client, "#{@api_namespace}/#{name}", %{"value" => value})

  @doc """
  Delete a specific global parameter.
  """
  @spec delete_global_parameter(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_global_parameter(client, name),
    do: Tesla.delete(client, "#{@api_namespace}/#{name}")
end
