defmodule LinkPreview.Mixfile do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      aliases: aliases(),
      app: :link_preview,
      deps: deps(),
      description: description(),
      docs: [
        extras: ["README.md", "CHANGELOG.md"]
      ],
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Link Preview",
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/iNeedThis/link_preview",
      test_coverage: [
        tool: ExCoveralls
      ],
      version: @version
    ]
  end

  defp description do
    """
    LinkPreview is a package that tries to receive meta information from given http(s) address.
    Generated page struct includes website title, description, images and more.
    """
  end

  defp package do
    [
      files: ["lib", "config", "mix.exs", "README.md", "CHANGELOG.md"],
      maintainers: ["Michael Cloutier"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/iNeedThis/link_preview"
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl],
      mod: {LinkPreview.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # required
      {:floki, "~> 0.37"},
      {:finch, "~> 0.19"},
      {:tesla, "~> 1.14"},

      # optional
      {:html_entities, "~> 0.5", optional: true},
      {:mogrify, "~> 0.9", optional: true},
      {:temp, "~> 0.4", optional: true},

      # testing/docs
      {:excoveralls, "~> 0.18", only: :test},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      {:httparrot, "~> 1.3", only: :test},
      {:mock, "~> 0.3", only: :test},
      {:mix_audit, "~> 2.1", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      test: ["test --exclude excluded"],
      audit: ["deps.audit"]
    ]
  end
end
