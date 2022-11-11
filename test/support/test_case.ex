defmodule ExRabbitMQAdmin.TestCase do
  use ExUnit.CaseTemplate

  defmodule Client do
    use ExRabbitMQAdmin.Client, otp_app: :ex_rabbitmq_admin
  end

  using do
    quote do
      import Tesla.Mock
      import TestHelper.Fixture
      alias ExRabbitMQAdmin.TestCase.Client
    end
  end

  setup _tags do
    Application.put_env(:ex_rabbitmq_admin, ExRabbitMQAdmin.TestCase.Client,
      base_url: "https://rabbitmq.example.com:5672",
      username: "guest",
      password: "guest"
    )

    on_exit(fn ->
      Application.delete_env(:ex_rabbitmq_admin, ExRabbitMQAdmin.TestCase.Client)
    end)

    :ok
  end
end
