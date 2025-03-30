defmodule RayexHacking.MixProject do
  use Mix.Project

  def project do
    [
      app: :rayex_hacking,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RayexHacking.Application, []}
    ]
  end

  defp deps do
    [
      # {:rayex, "~> 0.0.3"}
      {:rayex, path: "../rayex"}
    ]
  end
end
