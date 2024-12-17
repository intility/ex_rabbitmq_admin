defmodule ExRabbitMQAdmin.Binding do
  @moduledoc """
  RabbitMQ Bindings.
  """
  import ExRabbitMQAdmin.Options,
    only: [
      create_exchange_binding_definition: 0,
      format_error: 1
    ]

  @api_namespace "/api/bindings"

  @doc """
  List all bindings on the RabbitMQ cluster.
  """
  @spec list_bindings(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_bindings(client), do: Tesla.get(client, @api_namespace)

  @doc """
  List all bindings in a given virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
  """
  @spec list_vhost_bindings(client :: Tesla.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_vhost_bindings(client, vhost), do: Tesla.get(client, "#{@api_namespace}/#{vhost}")

  @doc """
  List all bindings between an exchange and a queue in a given virtual host.
  """
  @spec list_exchange_queue_bindings(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          exchange :: String.t(),
          queue :: String.t()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_exchange_queue_bindings(client, vhost, exchange, queue),
    do: Tesla.get(client, "#{@api_namespace}/#{vhost}/e/#{exchange}/q/#{queue}")

  @doc """
  Create a binding between an exchange and a queue in a given virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    * `exchange` - type: `string`, required: `true`
    * `queue` - type: `string`, required: `true`
    #{NimbleOptions.docs(create_exchange_binding_definition())}

  The response will contain a `Location` header with the URI of the newly created binding.
  """
  @spec create_exchange_queue_binding(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          exchange :: String.t(),
          queue :: String.t(),
          opts :: Keyword.t()
        ) :: {:ok, Tesla.Env.t()} | no_return()
  def create_exchange_queue_binding(client, vhost, exchange, queue, opts) do
    case NimbleOptions.validate(opts, create_exchange_binding_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, params} ->
        client
        |> Tesla.post(
          "#{@api_namespace}/#{vhost}/e/#{exchange}/q/#{queue}",
          Enum.into(params, %{})
        )
    end
  end

  @doc """
  List all bindings between two exchanges in a given virtual host.
  """
  @spec list_exchange_exchange_bindings(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          src :: String.t(),
          dest :: String.t()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_exchange_exchange_bindings(client, vhost, src, dest),
    do: Tesla.get(client, "#{@api_namespace}/#{vhost}/e/#{src}/e/#{dest}")

  @doc """
  Create a binding between two exchanges in a given virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    * `src` - type: `string`, required: `true`
    * `dest` - type: `string`, required: `true`
    #{NimbleOptions.docs(create_exchange_binding_definition())}

  The response will contain a `Location` header with the URI of the newly created binding.
  """
  @spec create_exchange_exchange_binding(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          src :: String.t(),
          dest :: String.t(),
          opts :: Keyword.t()
        ) :: {:ok, Tesla.Env.t()} | no_return()
  def create_exchange_exchange_binding(client, vhost, src, dest, opts) do
    case NimbleOptions.validate(opts, create_exchange_binding_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, params} ->
        client
        |> Tesla.post("#{@api_namespace}/#{vhost}/e/#{src}/e/#{dest}", Enum.into(params, %{}))
    end
  end
end
