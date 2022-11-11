defmodule ExRabbitMQAdmin.VHost do
  @moduledoc """
  This module contains functions for interacting with RabbitMQ VHosts.
  """

  @doc """
  List all virtual hosts running on the RabbitMQ cluster.
  """
  @spec list_vhosts(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()}
  def list_vhosts(client), do: client |> Tesla.get("/api/vhosts")

  @doc """
  List all open open connections in a specific virtual host.
  Optionally pass pagination parameters to filter connections.

  ### Params

    * `name` - type: `binary`, required: `true`
    * `params` - type: `map`, reqiured: `false`

        * `page` - type: `non_neg_integer`, required: `false`
        * `page_size` - type: `non_neg_integer`, required: `false`
        * `use_regex` - type: `boolean`, required: `false`

        ```
        %{
          "page" => 1,
          "page_size" => 100,
          "use_regex" => true
        }

        ```
  """
  @spec list_vhost_connections(client :: Tesla.Client.t(), name :: String.t(), params :: map()) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_connections(client, name, params \\ %{}) do
    client |> Tesla.get("/api/vhosts/#{name}/connections", params)
  end

  @doc """
  List all open channels for a specific virtual host.
  Optionally pass pagination parameters to filter channels.

  ### Params

    * `name` - type: `binary`, required: `true`
    * `params` - type: `map`, reqiured: `false`

        * `page` - type: `non_neg_integer`, required: `false`
        * `page_size` - type: `non_neg_integer`, required: `false`
        * `use_regex` - type: `boolean`, required: `false`

        ```
        %{
          "page" => 1,
          "page_size" => 100,
          "use_regex" => true
        }

        ```
  """
  @spec list_vhost_channels(client :: Tesla.Client.t(), name :: String.t(), params :: map()) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_channels(client, name, params \\ %{}) do
    client |> Tesla.get("/api/vhosts/#{name}/channels", params)
  end

  @doc """
  List all permissions for a specific virtual host.
  """
  @spec list_vhost_permissions(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_permissions(client, name) do
    client |> Tesla.get("/api/vhosts/#{name}/permissions")
  end

  @doc """
  List all topic permissions for a specific virtual host.
  """
  @spec list_vhost_topic_permissions(client :: Tesla.Client.t(), name :: String.t()) ::
          {:ok, Tesla.Env.t()}
  def list_vhost_topic_permissions(client, name) do
    client |> Tesla.get("/api/vhosts/#{name}/topic-permissions")
  end

  @doc """
  Get an individual virtual host by name.
  """
  @spec get_vhost(client :: Telsa.Client.t(), name :: String.t()) :: {:ok, Tesla.Env.t()}
  def get_vhost(client, name) when is_binary(name), do: client |> Tesla.get("/api/vhosts/#{name}")

  @doc """
  Create a new virtual host with given name.

  ### Params

    * `params` - type: `map`

      * `name` - type: `binary`, required: `true`
      * `description` - type: `binary`, required: `false`
      * `tags` - type: `binary`, required: `false`. Comma-separated list of tags to be set on the virtual host

      ```
      %{
        "name" => "accounting",
        "description" => "this vhost is for accounting messages",
        "tags" => "finance,production"
      }
      ```
  """
  @spec put_vhost(client :: Telsa.Client.t(), params :: map) :: {:ok, Tesla.Env.t()}
  def put_vhost(client, %{"name" => name} = params),
    do: client |> Tesla.put("/api/vhosts/#{name}", params)

  @doc """
  Delete a specific virtual host by name.
  """
  @spec delete_vhost(client :: Tesla.Client.t(), name :: String.t()) :: {:ok, Tesla.Env.t()}
  def delete_vhost(client, name), do: client |> Tesla.delete("/api/vhosts/#{name}")

  @doc """
  Start a specific virtual host on given node.
  """
  @spec start_vhost(client :: Tesla.Client.t(), name :: String.t(), node :: String.t()) ::
          {:ok, Tesla.Env.t()}
  def start_vhost(client, name, node) do
    client |> Tesla.post("/api/vhosts/#{name}/start/#{node}")
  end
end
