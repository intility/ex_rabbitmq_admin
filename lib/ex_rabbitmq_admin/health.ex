defmodule ExRabbitMQAdmin.Health do
  @moduledoc """
  This module contains functions for RabbitMQ health checks.
  """

  @doc """
  Basic aliveness test. Declares a test queue, publishes and consumes a message.
  """
  @spec aliveness_test(client :: Tesla.Client.t(), vhost :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def aliveness_test(client, vhost), do: Tesla.get(client, "/api/aliveness-test/#{vhost}")

  @doc """
  Check if there are any resource alarms in the cluster.
  """
  @spec check_alarms(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def check_alarms(client), do: Tesla.get(client, "/api/health/checks/alarms")

  @doc """
  Check if there are any local resource alarms on the target node.
  """
  @spec check_local_alarms(client :: Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def check_local_alarms(client), do: Tesla.get(client, "/api/health/checks/local-alarms")

  @doc """
  Check if any TLS certificates expire within the given time window.
  """
  @spec check_certificate_expiration(
          client :: Tesla.Client.t(),
          within :: integer(),
          unit :: String.t()
        ) :: {:ok, Tesla.Env.t()} | {:error, term()}
  def check_certificate_expiration(client, within, unit) do
    Tesla.get(client, "/api/health/checks/certificate-expiration/#{within}/#{unit}")
  end

  @doc """
  Check if there is an active listener on the given port.
  """
  @spec check_port_listener(client :: Tesla.Client.t(), port :: integer()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def check_port_listener(client, port),
    do: Tesla.get(client, "/api/health/checks/port-listener/#{port}")

  @doc """
  Check if there is an active listener for the given protocol.
  """
  @spec check_protocol_listener(client :: Tesla.Client.t(), protocol :: String.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def check_protocol_listener(client, protocol),
    do: Tesla.get(client, "/api/health/checks/protocol-listener/#{protocol}")

  @doc """
  Check if all virtual hosts and their resources are running.
  """
  @spec check_virtual_hosts(client :: Tesla.Client.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def check_virtual_hosts(client), do: Tesla.get(client, "/api/health/checks/virtual-hosts")

  @doc """
  Check if there are classic mirrored queues without synchronised mirrors online.
  """
  @spec check_mirror_sync_critical(client :: Tesla.Client.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def check_mirror_sync_critical(client),
    do: Tesla.get(client, "/api/health/checks/node-is-mirror-sync-critical")

  @doc """
  Check if there are quorum queues with minimum online quorum.
  """
  @spec check_quorum_critical(client :: Tesla.Client.t()) ::
          {:ok, Tesla.Env.t()} | {:error, term()}
  def check_quorum_critical(client),
    do: Tesla.get(client, "/api/health/checks/node-is-quorum-critical")
end
