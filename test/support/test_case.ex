defmodule ExRabbitMQAdmin.TestCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  defmodule Client do
    @moduledoc false
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

    :ok
  end
end
