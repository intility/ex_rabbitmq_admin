defmodule ExRabbitMQAdmin.Parameter do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ vhost-scoped parameters.
  """

  @api_namespace "/api/parameters"

  @doc """
  Get a list of all vhost-scoped parameters.
  """
  @spec list_parameters(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_parameters(client), do: Tesla.get(client, @api_namespace)

  @doc """
  Get a list of all vhost-scoped parameters for a given component.
  """
  @spec list_component_parameters(client :: Tesla.Client.t(), component :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_component_parameters(client, component),
    do: Tesla.get(client, "#{@api_namespace}/#{component}")

  @doc """
  Get a list of all vhost-scoped parameters for a given component on a specific vhost.
  """
  @spec list_component_vhost_parameters(
          client :: Tesla.Client.t(),
          component :: String.t(),
          vhost :: String.t()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_component_vhost_parameters(client, component, vhost),
    do: Tesla.get(client, "#{@api_namespace}/#{component}/#{vhost}")

  @doc """
  Get a specific vhost-scoped parameter.
  """
  @spec get_parameter(
          client :: Tesla.Client.t(),
          component :: String.t(),
          vhost :: String.t(),
          name :: String.t()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def get_parameter(client, component, vhost, name),
    do: Tesla.get(client, "#{@api_namespace}/#{component}/#{vhost}/#{name}")

  @doc """
  Set a specific vhost-scoped parameter.
  """
  @spec put_parameter(
          client :: Tesla.Client.t(),
          component :: String.t(),
          vhost :: String.t(),
          name :: String.t(),
          value :: term()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def put_parameter(client, component, vhost, name, value),
    do: Tesla.put(client, "#{@api_namespace}/#{component}/#{vhost}/#{name}", %{"value" => value})

  @doc """
  Delete a specific vhost-scoped parameter.
  """
  @spec delete_parameter(
          client :: Tesla.Client.t(),
          component :: String.t(),
          vhost :: String.t(),
          name :: String.t()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_parameter(client, component, vhost, name),
    do: Tesla.delete(client, "#{@api_namespace}/#{component}/#{vhost}/#{name}")
end
