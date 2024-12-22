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

  @doc """
  Get various bits of infroamtion about the RabbitMQ cluster.
  """
  @spec overview(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def overview(client), do: Tesla.get(client, "/api/overview")

  @doc """
  Get the name of the RabbitMQ cluster.
  """
  @spec cluster_name(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def cluster_name(client), do: Tesla.get(client, "/api/cluster-name")

  @doc """
  Get a list of extensions to the management plugin.
  """
  @spec extensions(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def extensions(client), do: Tesla.get(client, "/api/extensions")

  @doc """
  Get details of the currently authenticated user.
  """
  @spec whoami(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def whoami(client), do: Tesla.get(client, "/api/whoami")
end
