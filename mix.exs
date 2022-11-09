defmodule ExRabbitMQAdmin.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "A Http client library for RabbitMQ Web API"
  @source_url "https://github.com/Intility/ex_rabbitmqadmin"

  def project do
    [
      app: :ex_rabbitmqadmin,
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: @description,
      deps: deps(),
      package: [
        name: "ex_rabbitmqadmin",
        maintainers: ["Rolf Håvard Blindheim <rolf.havard.blindheim@intility.no>"],
        licenses: ["Apache-2.0"],
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
      test_coverage: [
        [tool: ExCoveralls],
        summary: [threshold: 90]
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
      {:excoveralls, "~> 0.15.0", only: :test},
      {:hackney, "~> 1.18", optional: true},
      {:jason, "~> 1.4"},
      {:tesla, "~> 1.4"}
    ]
  end
end
