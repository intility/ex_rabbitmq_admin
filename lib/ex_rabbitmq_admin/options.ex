defmodule ExRabbitMQAdmin.Options do
  @moduledoc """

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

  def format_error(%ValidationError{keys_path: [], message: message}), do: message

  def format_error(%ValidationError{keys_path: keys_path, message: message}) do
    "invalid parameter for key #{inspect(keys_path)}, #{message}"
  end
end
