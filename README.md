[![Build Status](https://github.com/iNeedThis/link_preview/actions/workflows/ci.yml/badge.svg)](https://github.com/iNeedThis/link_preview/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/iNeedThis/link_preview/badge.svg?branch=main)](https://coveralls.io/github/iNeedThis/link_preview?branch=main)
[![Hex.pm](https://img.shields.io/hexpm/v/link_preview.svg?style=flat&colorB=6B4D90)](https://hex.pm/packages/link_preview)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/link_preview/)

# LinkPreview

[![Build Status](https://travis-ci.org/appunite/link_preview.svg?branch=master)](https://travis-ci.org/appunite/link_preview)
[![Coverage Status](https://coveralls.io/repos/github/appunite/link_preview/badge.svg?branch=master)](https://coveralls.io/github/appunite/link_preview?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/link_preview.svg?style=flat&colorB=6B4D90)](https://hex.pm/packages/link_preview)

**LinkPreview** is a modern Elixir package that extracts meta information from HTTP(S) URLs, perfect for building Reddit-style link previews, social media cards, and rich content displays.

## Features

- 🚀 **Modern & Fast**: Built with latest dependencies (Finch, Tesla, Floki)
- 🎯 **Rich Metadata**: Extracts titles, descriptions, images, and Open Graph data
- 🔧 **Flexible**: Multiple parsing strategies (HTML, Open Graph, Twitter Cards)
- 🛡️ **Robust**: Comprehensive error handling and optional dependencies
- 📱 **Social Ready**: Perfect for social media, chat apps, and content platforms
- 🧪 **Well Tested**: Comprehensive test suite with 67+ tests

## Installation

Add `link_preview` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:link_preview, "~> 1.1"}
  ]
end
```

For Elixir < 1.15, ensure link_preview is started before your application:

```elixir
def application do
  [extra_applications: [:link_preview]]
end
```

## Quick Start

```elixir
# Basic usage
{:ok, page} = LinkPreview.create("https://github.com")

%LinkPreview.Page{
  title: "GitHub: Let's build from here",
  description: "GitHub is where over 100 million developers shape the future...",
  images: [%{url: "https://github.githubassets.com/images/modules/site/social-cards/github-social.png"}],
  original_url: "https://github.com",
  website_url: "github.com"
}
```

## Usage Examples

### Reddit-Style Link Previews

```elixir
defmodule MyApp.LinkPreviewController do
  use MyAppWeb, :controller

  def create(conn, %{"url" => url}) do
    case LinkPreview.create(url) do
      {:ok, page} ->
        json(conn, %{
          title: page.title,
          description: page.description,
          image: get_absolute_image_url(page),
          url: page.original_url,
          domain: page.website_url
        })
      {:error, reason} ->
        json(conn, %{error: "Could not fetch preview: #{reason}"})
    end
  end

  defp get_absolute_image_url(%{images: []}), do: nil
  defp get_absolute_image_url(%{images: [%{url: "/" <> path} | _], website_url: domain}) do
    "https://#{domain}/#{path}"
  end
  defp get_absolute_image_url(%{images: [%{url: url} | _]}), do: url
end
```

### Phoenix LiveView Integration

```elixir
defmodule MyAppWeb.PostLive do
  use Phoenix.LiveView

  def handle_event("preview_link", %{"url" => url}, socket) do
    case LinkPreview.create(url) do
      {:ok, page} ->
        {:noreply, assign(socket, :link_preview, page)}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not generate preview")}
    end
  end
end
```

### Caching Link Previews

```elixir
defmodule MyApp.CachedLinkPreview do
  @cache_ttl :timer.hours(24)

  def get_or_create(url) do
    case Cachex.get(:link_cache, url) do
      {:ok, nil} ->
        case LinkPreview.create(url) do
          {:ok, page} = result ->
            Cachex.put(:link_cache, url, page, ttl: @cache_ttl)
            result
          error -> error
        end
      {:ok, cached_page} ->
        {:ok, cached_page}
    end
  end
end
```

## Configuration

LinkPreview supports various configuration options:

```elixir
# config/config.exs
config :link_preview,
  # Enable friendly string processing (default: true)
  friendly_strings: true,

  # Force absolute URLs for images (default: false)
  force_images_absolute_url: true,

  # Force URL schema (http://) for images (default: false)
  force_images_url_schema: true,

  # Filter small images (requires Mogrify and Temp packages)
  filter_small_images: 100  # minimum dimension in pixels
```

## Optional Dependencies

For enhanced functionality, you can add these optional dependencies:

```elixir
def deps do
  [
    {:link_preview, "~> 1.1"},

    # For HTML entity decoding
    {:html_entities, "~> 0.5"},

    # For image size filtering
    {:mogrify, "~> 0.9"},
    {:temp, "~> 0.4"}
  ]
end
```

## API Reference

### LinkPreview.create/1

Extracts metadata from a given URL.

**Parameters:**
- `url` (String) - The URL to extract metadata from

**Returns:**
- `{:ok, %LinkPreview.Page{}}` - Success with extracted metadata
- `{:error, reason}` - Error with reason

### LinkPreview.Page

The main data structure containing extracted metadata:

```elixir
%LinkPreview.Page{
  title: "Page Title",           # String | nil
  description: "Page description", # String | nil
  images: [%{url: "image_url"}], # List of image maps
  original_url: "input_url",     # String
  website_url: "domain.com"      # String
}
```

## Supported Metadata Sources

LinkPreview automatically detects and extracts from:

- **Open Graph** (`og:title`, `og:description`, `og:image`)
- **Twitter Cards** (`twitter:title`, `twitter:description`, `twitter:image`)
- **HTML Meta Tags** (`<meta name="description">`)
- **HTML Elements** (`<title>`, `<h1>-<h6>`, `<img>`)

## Testing

```bash
# Run tests
mix test

# Run tests with coverage
mix test --cover

# Run tests with detailed coverage
mix coveralls.html
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed changes.

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## Credits

Originally created by Tobiasz Małecki and Karol Wojtaszek at AppUnite. Modernized and maintained by the community.

---

**Perfect for building:**
- Social media platforms
- Chat applications
- Content management systems
- Link sharing platforms
- Rich text editors
- News aggregators
