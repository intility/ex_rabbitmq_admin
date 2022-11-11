import Config

case config_env() do
  :dev ->
    config :mix_test_watch, tasks: ["test --cover"]

    config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

    config :ex_rabbitmq_admin, ExRabbitMQAdmin.Client,
      base_url: System.get_env("RABBITMQ_HTTP_BASE_URL", "http://localhost:5672"),
      username: "guest",
      password: "guest"

  :test ->
    config :tesla, adapter: Tesla.Mock
end
