defmodule ExRabbitMQAdmin.Policy do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ policies.
  """

  import ExRabbitMQAdmin.Options,
    only: [put_policy_definition: 0, format_error: 1]

  @api_namespace "/api/policies"

  @doc """
  Get a list of all policies.
  """
  @spec list_policies(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_policies(client), do: Tesla.get(client, @api_namespace)

  @doc """
  Get a list of policies in a virtual host.
  """
  @spec list_vhost_policies(client :: Tesla.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_vhost_policies(client, vhost), do: Tesla.get(client, "#{@api_namespace}/#{vhost}")

  @doc """
  Get an individual policy.
  """
  @spec get_policy(client :: Tesla.Client.t(), vhost :: String.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_policy(client, vhost, name),
    do: Tesla.get(client, "#{@api_namespace}/#{vhost}/#{name}")

  @doc """
  Create or update a policy.

  #{NimbleOptions.docs(put_policy_definition())}
  """
  @spec put_policy(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          name :: String.t(),
          opts :: Keyword.t()
        ) ::
          {:ok, Tesla.Env.t()} | no_return()
  def put_policy(client, vhost, name, opts \\ []) do
    case NimbleOptions.validate(opts, put_policy_definition()) do
      {:ok, params} ->
        Tesla.put(client, "#{@api_namespace}/#{vhost}/#{name}", Enum.into(params, %{}))

      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end

  @doc """
  Delete a policy.
  """
  @spec delete_policy(client :: Tesla.Client.t(), vhost :: String.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_policy(client, vhost, name),
    do: Tesla.delete(client, "#{@api_namespace}/#{vhost}/#{name}")
end
