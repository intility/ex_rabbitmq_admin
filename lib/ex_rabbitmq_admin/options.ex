defmodule ExRabbitMQAdmin.Options do
  @moduledoc false
  alias NimbleOptions.ValidationError

  def pagination_definition do
    [
      page: [
        doc: """
        Page number to fetch if paginating the results.
        """,
        type: :non_neg_integer
      ],
      page_size: [
        doc: """
        Number of elements per page, defaults to 100.
        """,
        type: :non_neg_integer
      ],
      name: [
        doc: """
        Filter by name, for example queue name, exchange name, etc.
        """,
        type: :string
      ],
      use_regex: [
        doc: """
        Enables regular expression for the param `name`.
        """,
        type: :boolean
      ]
    ]
  end

  def put_user_definition do
    [
      password: [
        doc: """
        The password that will be used for the created user. All passwords will be hashed using the
        `rabbit_password_hashing_sha512` hashing algorithm before sent to over the wire.
        If blank password, users will not be able to login using a password, but other mechanisms
        like client certificates may be used.
        """,
        type: :string,
        required: true
      ],
      tags: [
        doc: """
        Comma-separated list of tags for the user. Currently only `administrator`, `monitoring`
        and `management` are recognized.
        """,
        type: :string,
        required: true
      ]
    ]
  end

  def put_vhost_definition do
    [
      description: [
        doc: """
        Optional description for virtual host.
        """,
        type: :string,
        default: ""
      ],
      tags: [
        doc: """
        Tags is an optional comma-separated list of tags.
        """,
        type: :string,
        default: ""
      ]
    ]
  end

  def put_vhost_permissions do
    [
      configure: [
        doc: """
        A regular expression that will determine the `configure` permissions for the given resource.
        Defaults to deny-all.
        """,
        type: :string,
        required: true,
        default: "^$"
      ],
      write: [
        doc: """
        A regular expression that will determine the `write` permissions for the given resource.
        Defaults to deny-all.
        """,
        type: :string,
        required: true,
        default: "^$"
      ],
      read: [
        doc: """
        A regular expression that will determine the `read` permissions for the given resource.
        Defaults to deny-all.
        """,
        type: :string,
        required: true,
        default: "^$"
      ]
    ]
  end

  def receive_messages_definition do
    [
      count: [
        doc: """
        Maximum number of messages to receive. You may get fewer messages if the queue
        cannot immediately provide them.
        """,
        type: :pos_integer,
        default: 1
      ],
      ackmode: [
        doc: """
        Determines if the messages will be removed from the queue. If set to `ack_requeue_true`
        or `reject_requeue_true`, the messages will be re-queued. If set to `ack_requeue_false`,
        or `reject_requeue_false`, they will be removed.
        """,
        type:
          {:in,
           [
             :ack_requeue_true,
             :ack_requeue_false,
             :reject_requeue_true,
             :reject_requeue_false
           ]},
        required: true
      ],
      encoding: [
        doc: """
        If set to `auto`, message payload will be returned as string if it is valid UTF-8, or
        base64 encoded otherwise. If set to `base64` message payload will always be base64 encoded.
        """,
        type: {:in, [:auto, :base64]},
        default: :auto
      ],
      truncate: [
        doc: """
        If present, truncate the message payload if larger than given size (in bytes).
        """,
        type: :pos_integer
      ]
    ]
  end

  def put_queue_definition do
    [
      auto_delete: [
        doc: """
        If true, automatically delete the queue when the last consumer disconnects.
        """,
        type: :boolean,
        default: false
      ],
      durable: [
        doc: """
        If true, messages are persisted on disk. This can lead to lower throughput, but better
        data consistency.
        """,
        type: :boolean,
        default: true
      ],
      node: [
        doc: """
        If set, start the queue on given node name.
        """,
        type: :string,
        required: false
      ],
      arguments: [
        doc: """
        Optional queue arguments (x-arguments) passed to RabbitMQ when creating the queue.
        Please consult the official documentation for supported arguments (as they vary for
        queue type and installed plugins).
        """,
        type: {:map, :string, :any},
        required: false
      ]
    ]
  end

  def delete_queue_definition do
    [
      if_empty: [
        doc: """
        If true, prevent deleting the queue if it contains any messages.
        This option is not supported by `quorum` queues.
        """,
        type: :boolean,
        required: false
      ],
      if_unused: [
        doc: """
        If true, prevent deleting the queue if it has any consumers.
        This option is not supported by `quorum` queues.
        """,
        type: :boolean,
        required: false
      ]
    ]
  end

  def put_exchange_definition do
    [
      arguments: [
        doc: """
        Optional exchange arguments passed to RabbitMQ when creating the exchange.
        Please consult the official documentation for supported arguments (as they can vary
        for exchange type).
        """,
        type: {:map, :string, :any},
        required: false
      ],
      auto_delete: [
        doc: """
        If true, the exchange is auto-deleted once the last bound object is unbound from
        the exchange.
        """,
        type: :boolean,
        default: false
      ],
      durable: [
        doc: """
        Durable exchanges survives server restarts and lasts until explicitly deleted.
        """,
        type: :boolean,
        default: true
      ],
      internal: [
        doc: """
        Internal exchanges are meant for internal RabbitMQ tasks only.
        """,
        type: :boolean,
        default: false
      ],
      type: [
        doc: """
        Exchange types defines how messages are routed by using different parameters and
        bindings.
        """,
        type: {:in, [:direct, :fanout, :headers, :topic]},
        default: :direct
      ]
    ]
  end

  def delete_exchange_definition do
    [
      if_unused: [
        doc: """
        If true, prevent deleting the exchange if it is bound to a queue or acts as a
        source for another exchange.
        """,
        type: :boolean,
        required: false
      ]
    ]
  end

  def publish_exchange_message_definition do
    [
      properties: [
        doc: """
        Message properties.
        """,
        type: {:map, :string, :any},
        default: %{}
      ],
      routing_key: [
        doc: """
        The routing key used to route the message to its destination.
        """,
        type: :string,
        required: true
      ],
      payload: [
        doc: """
        Message to be sent.
        """,
        type: {:or, [:map, :string]},
        required: true
      ],
      payload_encoding: [
        doc: """
        If set to `string` the payload will be sent as an UTF-8 encoded string.
        If `base64`, the message payload should be base64 encoded.
        """,
        type: {:in, [:string, :base64]},
        default: :string
      ]
    ]
  end

  def create_exchange_binding_definition do
    [
      routing_key: [
        doc: """
        The routing key used to route the message to its destination.
        """,
        type: :string,
        required: true
      ],
      arguments: [
        doc: """
        Optional binding arguments passed to RabbitMQ when creating the binding.
        Please consult the official documentation for supported arguments (as they can vary
        for exchange type).
        """,
        type: {:map, :string, :any},
        required: false
      ]
    ]
  end

  def get_node_definition do
    [
      memory: [
        doc: """
        If true, include memory statistics in the response.
        """,
        type: :boolean,
        default: false
      ],
      binary: [
        doc: """
        If true, include binary statistics in the response.
        """,
        type: :boolean,
        default: false
      ]
    ]
  end

  def format_error(%ValidationError{keys_path: [], message: message}), do: message

  def format_error(%ValidationError{keys_path: keys_path, message: message}) do
    "invalid parameter for key #{inspect(keys_path)}, #{message}"
  end
end
