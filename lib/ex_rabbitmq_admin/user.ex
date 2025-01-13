defmodule ExRabbitMQAdmin.User do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ users.
  """
  require Logger

  import ExRabbitMQAdmin.Options,
    only: [
      put_user_definition: 0,
      format_error: 1
    ]

  @api_namespace "/api/users"

  @doc """
  List all users in the RabbitMQ cluster.

  ### Params

    * `client` - Tesla client used to perform the request.
  """
  @spec list_users(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def list_users(client), do: client |> Tesla.get(@api_namespace)

  @doc """
  Get an individual user by name.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `user` - type: `string`, required: `true`
  """
  @spec get_user(client :: Tesla.Client.t(), user :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_user(client, user), do: client |> Tesla.get("#{@api_namespace}/#{user}")

  @doc """
  Create a new user with given name.
  RabbitMQ currently only supports weak password hashing algorithms, and
  should be avoided if possible. If passing a blank password, a password-less
  user will be created. This user will not be able to authenticate with
  basic auth, and must use other means (such as TLS certificates).

  ### Params

    * `client` - Tesla client used to perform the request.
    * `user` - type: `string`, required: `true`
    #{NimbleOptions.docs(put_user_definition())}
  """
  @spec put_user(client :: Tesla.Client.t(), user :: String.t(), opts :: Keyword.t()) ::
          {:ok, Tesla.Env.t()} | no_return()
  def put_user(client, user, opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, put_user_definition()),
         {:ok, password} <- Keyword.fetch(opts, :password),
         {:ok, password_hash} <- hash_password(password) do
      params =
        case password do
          "" ->
            Logger.info("Creating password-less user account for \"#{user}\"")

            Keyword.take(opts, [:tags])
            |> Keyword.merge(password_hash: "")
            |> Enum.into(%{})

          _ ->
            Keyword.take(opts, [:tags])
            |> Keyword.merge(
              password_hash: password_hash,
              hashing_algorithm: "rabbit_password_hashing_sha512"
            )
            |> Enum.into(%{})
        end

      client |> Tesla.put("#{@api_namespace}/#{user}", params)
    else
      {:error, error} ->
        raise ArgumentError, format_error(error)
    end
  end

  @doc """
  Deletes an individual user by given name.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `user` - type: `string`, required: `true`
  """
  @spec delete_user(client :: Tesla.Client.t(), user :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def delete_user(client, user), do: client |> Tesla.delete("#{@api_namespace}/#{user}")

  @doc """
  Delete all users in given list.

  ### Params

    * `client` - Tesla client used to perform the request.
  """
  @spec bulk_delete_users(client :: Tesla.Client.t(), users :: [String.t()]) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def bulk_delete_users(client, [user | _rest] = users) when is_binary(user),
    do: client |> Tesla.post("#{@api_namespace}/bulk-delete", %{"users" => users})

  @doc """
  List users in the RabbitMQ cluster that have no access to any virtual host.

  ### Params

    * `client` - Tesla client used to perform the request.
  """
  @spec list_users_without_permissions(client :: Tesla.Client.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def list_users_without_permissions(client),
    do: client |> Tesla.get("#{@api_namespace}/without-permissions")

  @doc """
  Get all permissions for an individual user.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `user` - type: `string`, required: `true`
  """
  @spec get_user_permissions(client :: Tesla.Client.t(), user :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_user_permissions(client, user),
    do: client |> Tesla.get("#{@api_namespace}/#{user}/permissions")

  @doc """
  Get all topic permissions for an individual user.

  ### Params

    * `client` - Tesla client used to perform the request.
    * `user` - type: `string`, required: `true`
  """
  @spec get_user_topic_permissions(client :: Tesla.Client.t(), user :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def get_user_topic_permissions(client, user),
    do: client |> Tesla.get("#{@api_namespace}/#{user}/topic-permissions")

  @doc """
  Hash the given password using the hashing algorithm described
  [here](https://rabbitmq.com/passwords.html#computing-password-hash).

  RabbitMQ by default relies on (weak) hashed password, but we're enforcing
  the strongest supported hashing algorithm (sha512).

  If possible, avoid using passwords and authenticate using other means
  such as [TLS certificates](https://rabbitmq.com/passwords.html#x509-certificate-authentication).

  ### Params

    * `password` - type: `string`, required: `true`
  """
  @spec hash_password(password :: String.t()) :: {:ok, String.t()}
  def hash_password(password) do
    # Seed the PRNG
    :crypto.rand_seed()

    # 32bit random seed
    seed = :crypto.strong_rand_bytes(4)

    # Seed, hash and encode as specified in the documentation
    hashed_password =
      :crypto.hash(:sha512, seed <> password)
      |> then(fn seeded_password -> seed <> seeded_password end)
      |> Base.encode64()

    {:ok, hashed_password}
  end
end
