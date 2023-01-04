defmodule ExRabbitMQAdmin.Client do
  @moduledoc """
  Macro for creating RabbitMQ HTTP API client.

  ### Configuration

  Some options, such as e.g. `base_url` are read from the config. For each module that
  uses this macro, add an entry to your `config.exs` as:

      # config.ex
      config :my_app, MyApp.RabbitClient,
        base_url: "https://rabbitmq.example.com:15672",
        username: "guest",
        password: "guest"

  #### Parameters

  * `otp_app` - Namespace used to look up configuration values such as `base_url` and others.


  ### Example

      defmodule MyApp.RabbitClient do
        use ExRabbitMQAdmin.Client, otp_app: :my_app
      end

  """
  # coveralls-ignore-start
  defmacro __using__(opts) do
    {:ok, otp_app} = Keyword.fetch(opts, :otp_app)

    quote location: :keep do
      @spec client(opts :: Keyword.t()) :: Tesla.Client.t()
      def client, do: Application.get_env(unquote(otp_app), __MODULE__) |> client()

      def client(opts) do
        middleware = [
          {Tesla.Middleware.BaseUrl, client_option(opts, :base_url)},
          {Tesla.Middleware.Logger, filter_headers: ["authorization"]},
          {Tesla.Middleware.JSON, engine: Jason}
        ]

        Tesla.client(middleware)
      end

      @spec bearer_auth_middleware(client :: Tesla.Client.t(), opts :: Keyword.t()) :: [
              {Tesla.Middleware.BearerAuth, Keyword.t()}
            ]
      def bearer_auth_middleware(client, opts) when is_list(opts) do
        [
          {Tesla.Middleware.BearerAuth, token: client_option(opts, :token)}
          | Tesla.Client.middleware(client)
        ]
      end

      def add_bearer_auth_middleware(client, opts),
        do: bearer_auth_middleware(client, opts) |> Tesla.client()

      @spec basic_auth_middleware(client :: Tesla.Client.t(), opts :: Keyword.t()) ::
              [{Tesla.Middleware.BasicAuth, Keyword.t()}]
      def basic_auth_middleware(client, opts) when is_list(opts) do
        [
          {Tesla.Middleware.BasicAuth,
           username: client_option(opts, :username), password: client_option(opts, :password)}
          | Tesla.Client.middleware(client)
        ]
      end

      def basic_auth_middleware(client) do
        [
          {Tesla.Middleware.BasicAuth,
           username: client_option(:username), password: client_option(:password)}
          | Tesla.Client.middleware(client)
        ]
      end

      @spec add_basic_auth_middleware(client :: Tesla.Client.t(), opts :: Keyword.t()) ::
              Tesla.Client.t()
      def add_basic_auth_middleware(client, opts) when is_list(opts),
        do: basic_auth_middleware(client, opts) |> Tesla.client()

      def add_basic_auth_middleware(client), do: basic_auth_middleware(client) |> Tesla.client()

      @spec query_middleware(client :: Tesla.Client.t(), params :: Keyword.t()) ::
              [{Tesla.Middleware.Query, Keyword.t()}]
      def query_middleware(client, params),
        do: [{Tesla.Middleware.Query, params} | Tesla.Client.middleware(client)]

      @spec add_query_middleware(client :: Tesla.Client.t(), params :: Keyword.t()) ::
              Tesla.Client.t()
      def add_query_middleware(client, [{key, _} | _] = params) when is_atom(key),
        do: query_middleware(client, params) |> Tesla.client()

      def add_query_middleware(client, []), do: client

      def add_query_middleware(client, param, value) when is_atom(param),
        do: add_query_middleware(client, [{param, value}])

      @spec client_option(opts :: Keyword.t(), atom()) :: any()
      defp client_option(key) when is_atom(key),
        do: Application.get_env(unquote(otp_app), __MODULE__) |> client_option(key)

      defp client_option(opts, :base_url), do: Keyword.get(opts, :base_url, "")
      defp client_option(opts, :username), do: Keyword.get(opts, :username, "")
      defp client_option(opts, :password), do: Keyword.get(opts, :password, "")
      defp client_option(opts, :token), do: Keyword.get(opts, :token, "")
    end
  end

  # coveralls-ignore-stop
end
