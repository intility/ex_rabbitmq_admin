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

## Contribution

The RabbitMQ HTTP API is available [here](https://rawcdn.githack.com/rabbitmq/rabbitmq-server/v3.11.2/deps/rabbitmq_management/priv/www/api/index.html).

### Running the test suite

```shell
$ MIX_ENV=test mix coveralls
```
