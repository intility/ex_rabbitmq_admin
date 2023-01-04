defmodule ExRabbitMQAdmin.Queue do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ queues.
  """
  import ExRabbitMQAdmin.Options,
    only: [
      pagination_definition: 0,
      put_queue_definition: 0,
      delete_queue_definition: 0,
      receive_messages_definition: 0,
      format_error: 1
    ]

  @api_namespace "/api/queues"

  @doc """
  List all queues running on the RabbitMQ cluster.

  ### Params

    * `client` - Tesla client used to perform the request.
    #{NimbleOptions.docs(pagination_definition())}
  """
  @spec list_queues(client :: Tesla.Client.t(), opts :: Keyword.t()) :: {:ok, Tesla.Env.t()}
  def list_queues(client, opts \\ []) do
    case NimbleOptions.validate(opts, pagination_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, params} ->
        client
        |> ExRabbitMQAdmin.add_query_middleware(params)
        |> Tesla.get("#{@api_namespace}")
    end
  end

  @doc """
  List all queues in a given virtual host running on the RabbitMQ cluster.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - Name of the virtual host.
    #{NimbleOptions.docs(pagination_definition())}
  """
  @spec list_vhost_queues(client :: Tesla.Client.t(), vhost :: String.t(), opts :: Keyword.t()) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_queues(client, vhost, opts \\ []) do
    case NimbleOptions.validate(opts, pagination_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, params} ->
        client
        |> ExRabbitMQAdmin.add_query_middleware(params)
        |> Tesla.get("#{@api_namespace}/#{vhost}")
    end
  end

  @doc """
  List all bindings for a queue under a virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, Virtual host for the queue.
    * `queue` - type: `string`, Name of the queue to get bindings for.
  """
  @spec list_queue_bindings(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          queue :: String.t()
        ) :: {:ok, Tesla.Env.t()}
  def list_queue_bindings(client, vhost, queue),
    do: Tesla.get(client, "#{@api_namespace}/#{vhost}/#{queue}/bindings")

  @doc """
  Get an individual queue under a virtual host by name.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, Virtual host for the queue.
    * `queue` - type: `string`, Name of the queue to get.
  """
  @spec get_queue(client :: Tesla.Client.t(), vhost :: String.t(), queue :: String.t()) ::
          {:ok, Tesla.Env.t()}
  def get_queue(client, vhost, queue),
    do: Tesla.get(client, "#{@api_namespace}/#{vhost}/#{queue}")

  @doc """
  Create a new queue under a virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, Virtual host for the queue.
    * `queue` - type: `string`, Name of the queue to get.
    #{NimbleOptions.docs(put_queue_definition())}
  """
  @spec put_queue(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          queue :: String.t(),
          opts :: Keyword.t()
        ) :: {:ok, Tesla.Env.t()}
  def put_queue(client, vhost, queue, opts \\ []) do
    case NimbleOptions.validate(opts, put_queue_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, params} ->
        client
        |> Tesla.put("#{@api_namespace}/#{vhost}/#{queue}", Enum.into(params, %{}))
    end
  end

  @doc """
  Delete an existing queue under a virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, Virtual host for the queue.
    * `queue` - type: `string`, Name of the queue to delete.
    #{NimbleOptions.docs(delete_queue_definition())}
  """
  @spec delete_queue(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          queue :: String.t(),
          params :: KeyError.t()
        ) ::
          {:ok, Tesla.Env.t()}

  def delete_queue(client, vhost, queue, opts \\ []) do
    case NimbleOptions.validate(opts, delete_queue_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, params} ->
        params =
          Enum.reduce(params, [], fn
            {:if_empty, true}, acc -> Keyword.put(acc, :"if-empty", true)
            {:if_unused, true}, acc -> Keyword.put(acc, :"if-unused", true)
            _, acc -> acc
          end)

        client
        |> ExRabbitMQAdmin.add_query_middleware(params)
        |> Tesla.delete("#{@api_namespace}/#{vhost}/#{queue}")
    end
  end

  @doc """
  Purge all messages on a queue under a virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, Virtual host for the queue.
    * `queue` - type: `string`, Name of the queue to purge messages from.
  """
  @spec purge_queue(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          queue :: String.t()
        ) :: {:ok, Tesla.Env.t()}
  def purge_queue(client, vhost, queue),
    do: Tesla.delete(client, "#{@api_namespace}/#{vhost}/#{queue}/contents")

  @doc """
  Perform an action on a queue.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, Virtual host for the queue.
    * `queue` - type: `string`, Name of the queue to perform actions for.
    * `action` - type: `atom`, Action to perform. Currently only supports `:sync` and `:cancel_sync`
  """
  @spec perform_queue_action(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          queue :: String.t(),
          action :: :sync | :cancel_sync
        ) :: {:ok, Tesla.Env.t()}
  def perform_queue_action(client, vhost, queue, :sync) do
    Tesla.post(client, "#{@api_namespace}/#{vhost}/#{queue}/actions", %{"action" => "sync"})
  end

  def perform_queue_action(client, vhost, queue, :cancel_sync) do
    Tesla.post(client, "#{@api_namespace}/#{vhost}/#{queue}/actions", %{
      "action" => "cancel_sync"
    })
  end

  @doc """
  Receive messages from a queue under a virtual host.
  Please not that this is **not** an optimal way to consume messages
  from a queue. Consider using a library like
  [AMQP](https://hexdocs.pm/amqp/readme.html) for your daily dose
  of messages.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `vhost` - type: `string`, Virtual host for the queue.
    * `queue` - type: `string`, Name of the queue to receive messages from.
    #{NimbleOptions.docs(receive_messages_definition())}
  """
  @spec receive_queue_messages(
          client :: Tesla.Client.t(),
          vhost :: String.t(),
          queue :: String.t(),
          opts :: Keyword.t()
        ) :: {:ok, Tesla.Env.t()}
  def receive_queue_messages(client, vhost, queue, opts \\ []) do
    case NimbleOptions.validate(opts, receive_messages_definition()) do
      {:error, error} ->
        raise ArgumentError, format_error(error)

      {:ok, params} ->
        client
        |> Tesla.post("#{@api_namespace}/#{vhost}/#{queue}/get", Enum.into(params, %{}))
    end
  end
end
