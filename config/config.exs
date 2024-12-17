import Config

case config_env() do
  :dev ->
    config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

    config :ex_rabbitmq_admin, ExRabbitMQAdmin,
      base_url: System.get_env("RABBITMQ_HTTP_BASE_URL", "http://localhost:15672"),
      username: "guest",
      password: "guest"

  :test ->
    config :tesla, adapter: Tesla.Mock
end
