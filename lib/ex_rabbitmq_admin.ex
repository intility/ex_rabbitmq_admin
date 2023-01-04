defmodule ExRabbitMQAdmin do
  @moduledoc """
  Default module for the RabbitMQ admin client.

  ### Configuration

  This module uses the `ExRabbitMQAdmin.Client` macro, and can be configured
  in `config.exs`.

      # config.ex
      config :ex_rabbitmq_admin, ExRabbitMQAdmin,
        base_url: "https://rabbitmq.example.com:15672",
        username: "guest",
        password: "guest"


  ### Examples

  * Create a client, add basic auth by reading default values from config and
    list all virtual hosts running in the RabbitMQ cluster.

        iex> ExRabbitMQAdmin.client()
             |> ExRabbitMQAdmin.add_basic_auth_middleware()
             |> ExRabbitMQAdmin.Vhost.list_vhosts()
        {:ok, %Tesla.Env{status: 200, body: [...]}}
  """

  use ExRabbitMQAdmin.Client,
    otp_app: :ex_rabbitmq_admin
end
