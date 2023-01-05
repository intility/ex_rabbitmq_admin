defmodule ExRabbitMQAdmin.MixProject do
  use Mix.Project

  @version "0.1.1"
  @description "A Http client library for RabbitMQ Web API"
  @source_url "https://github.com/Intility/ex_rabbitmq_admin"

  def project do
    [
      app: :ex_rabbitmq_admin,
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: @description,
      deps: deps(),
      package: [
        name: "ex_rabbitmq_admin",
        maintainers: ["Rolf Håvard Blindheim <rolf.havard.blindheim@intility.no>"],
        licenses: ["MIT"],
        links: %{GitHub: @source_url}
      ],
      docs: [
        main: "readme",
        source_ref: "v#{@version}",
        source_url: @source_url,
        extras: [
          "README.md",
          "LICENSE"
        ]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.29", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.15", only: :test},
      {:hackney, "~> 1.18", optional: true},
      {:jason, "~> 1.4"},
      {:tesla, "~> 1.4"},
      {:nimble_options, "~> 0.5"}
    ]
  end
end
