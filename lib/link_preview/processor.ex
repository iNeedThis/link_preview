defmodule LinkPreview.Processor do
  @moduledoc """
    Combines the logic of other modules with user input.
  """
  alias LinkPreview.{Page, Requests}
  alias LinkPreview.Parsers.{Basic, Opengraph, Html, Image}

  @doc """
    Takes url and returns result of processing.
  """
  @spec call(String.t()) :: LinkPreview.success() | LinkPreview.failure()
  def call(url) do
    url
    |> Requests.head()
    |> case do
      {:ok, response} ->
        {:ok, response, response |> Tesla.get_header("content-type")}

      {:error, error} ->
        {:error, error, nil}
    end
    |> case do
      {:ok, %Tesla.Env{status: 200, url: final_url}, "text/html" <> _} ->
        parsers = Application.get_env(:link_preview, :parsers, [Opengraph, Html])

        do_call(url, final_url, parsers)

      {:ok, %Tesla.Env{status: 200, url: final_url}, "image/" <> _} ->
        do_image_call(url, final_url, [Image])

      {:ok, %Tesla.Env{status: status}, _} ->
        %LinkPreview.Error{origin: :http_status, message: "HTTP #{status}"}

      {:ok, _, content_type} ->
        %LinkPreview.Error{
          origin: :unsupported_content,
          message: "Unsupported content type: #{content_type}"
        }

      {:error, %Tesla.Error{reason: reason}, _} ->
        %LinkPreview.Error{origin: :network, message: "Network error: #{inspect(reason)}"}

      {:error, reason, _} ->
        %LinkPreview.Error{origin: :request, message: "Request failed: #{inspect(reason)}"}
    end
    |> to_tuple()
  catch
    :error, %{__struct__: origin, message: message} ->
      {:error, %LinkPreview.Error{origin: origin, message: message}}

    :error, reason ->
      {:error, %LinkPreview.Error{origin: :parsing, message: "Parsing error: #{inspect(reason)}"}}

    :exit, reason ->
      {:error,
       %LinkPreview.Error{origin: :timeout, message: "Request timeout: #{inspect(reason)}"}}

    _, reason ->
      {:error, %LinkPreview.Error{origin: :unknown, message: "Unknown error: #{inspect(reason)}"}}
  end

  defp to_tuple(result) do
    case result do
      %Page{} ->
        {:ok, result}

      %LinkPreview.Error{} ->
        {:error, result}
    end
  end

  defp do_image_call(url, final_url, parsers) do
    url
    |> Page.new(final_url)
    |> collect_data(parsers, nil)
  end

  defp do_call(url, final_url, parsers) do
    case Requests.get(url) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        url
        |> Page.new(final_url)
        |> collect_data(parsers, body)

      {:ok, %Tesla.Env{status: status}} ->
        %LinkPreview.Error{
          origin: :http_status,
          message: "GET request failed with HTTP #{status}"
        }

      {:error, %Tesla.Error{reason: reason}} ->
        %LinkPreview.Error{
          origin: :network,
          message: "GET request network error: #{inspect(reason)}"
        }

      {:error, reason} ->
        %LinkPreview.Error{origin: :request, message: "GET request failed: #{inspect(reason)}"}
    end
  end

  defp collect_data(page, parsers, body) do
    Enum.reduce(parsers, page, &apply_each_function(&1, &2, body))
  end

  defp apply_each_function(parser, page, body) do
    if Code.ensure_loaded?(parser) do
      Enum.reduce_while(Basic.parsable(), page, &apply_or_halt(parser, &1, &2, body))
    else
      page
    end
  end

  defp apply_or_halt(parser, :images, page, body) do
    current_value = Map.get(page, :images)

    if current_value == [] do
      {:cont, apply(parser, :images, [page, body])}
    else
      {:halt, page}
    end
  end

  defp apply_or_halt(parser, function, page, body) do
    current_value = Map.get(page, function)

    if is_nil(current_value) do
      {:cont, apply(parser, function, [page, body])}
    else
      {:halt, page}
    end
  end
end
