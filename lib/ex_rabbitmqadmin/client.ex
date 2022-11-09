defmodule ExRabbitMQAdmin.Client do
  @moduledoc """
  Write some docs here please!
  """
  @spec client(opts :: Keyword.t()) :: Tesla.Client.t()
  def client, do: Application.get_env(:ex_rabbitmqadmin, __MODULE__) |> client()

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

  # * Vhosts

  @doc """
  List all `vhosts`.
  """
  def list_vhosts(client), do: client |> Tesla.get("/api/vhosts")

  @doc """
  Get a single `vhost` by name.
  """
  def get_vhost(client, name) when is_binary(name), do: client |> Tesla.get("/api/vhosts/#{name}")

  @doc """
  Create a new `vhost` with given name.

  ### Params

    * `params` - type: map

    ```
    %{
      "name" => "accounting",
      "description" => "my virtual host description",
      "tags" => "accounts,production"
    }
    ```
  """
  def put_vhost(client, %{"name" => name} = params),
    do: client |> Tesla.put("/api/vhosts/#{name}", params)

  @doc """
  Delete a single `vhost` by name.
  """
  def delete_vhost(client, name) when is_binary(name),
    do: client |> Tesla.delete("/api/vhosts/#{name}")

  @spec client_option(opts :: Keyword.t(), atom()) :: any()
  defp client_option(key) when is_atom(key),
    do: Application.get_env(:ex_rabbitmqadmin, __MODULE__) |> client_option(key)

  defp client_option(opts, :base_url), do: Keyword.get(opts, :base_url)
  defp client_option(opts, :username), do: Keyword.get(opts, :username, "")
  defp client_option(opts, :password), do: Keyword.get(opts, :password, "")
  defp client_option(opts, :token), do: Keyword.get(opts, :token, "")
end
