# ExRabbitMQAdmin

Simple client library for the RabbitMQ [HTTP API](https://www.rabbitmq.com/management.html#http-api),
built on [Tesla](https://github.com/elixir-tesla/tesla).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_rabbitmq_admin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_rabbitmq_admin, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_rabbitmq_admin>.

### Example usage

First step is to set up some basic configuration in your `config.exs` file.

```elixir
# config.exs

config :ex_rabbitmq_admin, ExRabbitMQAdmin,
  base_url: "https://rabbitmq.example.com:56721"
```

Next, you can use the `ExRabbitMQAdmin` client from wherever you want.

```elixir
defmodule RabbitMQControl do
  alias ExRabbitMQAdmin

  @doc """
  Creates a new user on the RabbitMQ cluster.
  """
  def create_rabbit_user(username, password) do
    {:ok, %Tesla.Env{status: 201}} =
      ExRabbitMQAdmin.client()
      |> ExRabbitMQAdmin.add_basic_auth_middleware(username: "rabbit-admin", password: "secret-password")
      |> ExRabbitMQAdmin.User.put_user(username, password: password, tags: "moderator")
  end

  # Or maybe you want to list virtual hosts
  def virtual_hosts do
    {:ok, %Tesla.Env{:status: 200, body: response}} =
      ExRabbitMQAdmin.client()
      |> ExRabbitMQAdmin.add_basic_auth_middleware(username: "rabbit-admin", password: "secret-password")
      |> ExRabbitMQAdmin.Vhost.list_vhosts()
  end
end
```

## Contribution

The RabbitMQ HTTP API documentation is available [here](https://rawcdn.githack.com/rabbitmq/rabbitmq-server/v3.11.2/deps/rabbitmq_management/priv/www/api/index.html).

### Running the test suite

```shell
$ MIX_ENV=test mix coveralls.html
```
