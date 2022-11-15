defmodule ExRabbitMQAdmin.Options do
  @moduledoc """
  This module contains parameter validation rules.
  """
  alias NimbleOptions.ValidationError

  def pagination_definition do
    [
      page: [
        doc: """
        Page number to fetch if paginating the results.
        """,
        type: :non_neg_integer,
        default: 1
      ],
      page_size: [
        doc: """
        Number of elements per page, defaults to 100.
        """,
        type: :non_neg_integer,
        default: 100
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
        type: :boolean,
        default: false
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

  def format_error(%ValidationError{keys_path: [], message: message}), do: message

  def format_error(%ValidationError{keys_path: keys_path, message: message}) do
    "invalid parameter for key #{inspect(keys_path)}, #{message}"
  end
end
