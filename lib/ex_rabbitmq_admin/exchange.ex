defmodule ExRabbitMQAdmin.Exchange do
  @moduledoc """
  RabbitMQ Exchanges.
  """
  import ExRabbitMQAdmin.Options,
    only: [
      pagination_definition: 0,
      put_exchange_definition: 0,
      delete_exchange_definition: 0,
      publish_exchange_message_definition: 0,
      format_error: 1
    ]

  @api_namespace "/api/exchanges"

  @doc """
  List all exchanges on the RabbitMQ cluster.

  ### Params

    * `client` - Tesla client used to perform the request.
    #{NimbleOptions.docs(pagination_definition())}
  """
  @spec list_exchanges(client :: Tesla.Client.t(), opts :: Keyword.t()) ::
          {:ok, Tesla.Env.t()} | no_return()
  def list_exchanges(client, opts \\ []) do
    case NimbleOptions.validate(opts, pagination_definition()) do
      {:ok, params} ->
        client
        |> ExRabbitMQAdmin.add_query_middleware(params)
        |> Tesla.get(@api_namespace)

      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end

  @doc """
  List all exchanges in a given virtual host. Optionally pass pagination parameters
  to filter exchanges.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    #{NimbleOptions.docs(pagination_definition())}
  """
  @spec list_vhost_exchanges(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          opts :: Keyword.t()
        ) :: {:ok, Tesla.Env.t()} | no_return()
  def list_vhost_exchanges(client, vhost, opts \\ []) do
    case NimbleOptions.validate(opts, pagination_definition()) do
      {:ok, params} ->
        client
        |> ExRabbitMQAdmin.add_query_middleware(params)
        |> Tesla.get("#{@api_namespace}/#{vhost}")

      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end

  @doc """
  Get an individual exchange by name under a virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    * `name` - type: `string`, required: `true`
  """
  @spec get_exchange(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          name :: String.t()
        ) :: {:ok, Tesla.Env.t()} | no_return()
  def get_exchange(client, vhost, name),
    do: client |> Tesla.get("#{@api_namespace}/#{vhost}/#{name}")

  @doc """
  Create a new exchange under a virtual host with given name.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    * `name` - type: `string`, required: `true`
    #{NimbleOptions.docs(put_exchange_definition())}
  """
  @spec put_exchange(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          name :: String.t(),
          opts :: Keyword.t()
        ) :: {:ok, Tesla.Env.t()} | no_return()
  def put_exchange(client, vhost, name, opts \\ []) do
    case NimbleOptions.validate(opts, put_exchange_definition()) do
      {:ok, params} ->
        client
        |> Tesla.put("#{@api_namespace}/#{vhost}/#{name}", Enum.into(params, %{}))

      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end

  @doc """
  Delete a specific exchange under a virtual host by name.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    * `name` - type: `string`, required: `true`
    #{NimbleOptions.docs(delete_exchange_definition())}
  """
  @spec delete_exchange(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          name :: String.t(),
          opts :: Keyword.t()
        ) :: {:ok, Tesla.Env.t()} | no_return()
  def delete_exchange(client, vhost, name, opts \\ []) do
    case NimbleOptions.validate(opts, delete_exchange_definition()) do
      {:ok, params} ->
        params =
          Enum.reduce(params, [], fn
            {:if_unused, true}, acc -> Keyword.put(acc, :"if-unused", true)
            _, acc -> acc
          end)

        client
        |> ExRabbitMQAdmin.add_query_middleware(params)
        |> Tesla.delete("#{@api_namespace}/#{vhost}/#{name}")

      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end

  @doc """
  List all bindings in which the given exchange is the *source*.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    * `name` - type: `string`, required: `true`
  """
  @spec list_exchange_src_bindings(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          name :: String.t()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_exchange_src_bindings(client, vhost, name),
    do: client |> Tesla.get("#{@api_namespace}/#{vhost}/#{name}/bindings/source")

  @doc """
  List all bindings in which the given exchange is the *destination*.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    * `name` - type: `string`, required: `true`
  """
  @spec list_exchange_dest_bindings(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          name :: String.t()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_exchange_dest_bindings(client, vhost, name),
    do: client |> Tesla.get("#{@api_namespace}/#{vhost}/#{name}/bindings/destination")

  @doc """
  Publish a message to the given exchange.
  Please not that this is *not* an optimal way to publish messages
  to a queue. Consider using a library like [AMQP](https://hexdocs.pm/amqp/readme.html).

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, required: `true`
    * `name` - type: `string`, required: `true`
    #{NimbleOptions.docs(publish_exchange_message_definition())}


  If the message is published successfully to at least one queue,
  it will respond with:

  ```
  %{"routed" => true}
  ```
  """
  @spec publish_message(client :: Tesla.Client.t(), vhost :: String.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()} | no_return()
  def publish_message(client, vhost, name, opts \\ []) do
    case NimbleOptions.validate(opts, publish_exchange_message_definition()) do
      {:ok, params} ->
        client
        |> Tesla.post("#{@api_namespace}/#{vhost}/#{name}/publish", Enum.into(params, %{}))

      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end
end
