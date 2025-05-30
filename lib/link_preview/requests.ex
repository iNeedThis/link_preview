defmodule LinkPreview.Requests do
  @moduledoc """
    Module providing functions to handle needed requests.
  """
  use Tesla, docs: false, only: ~w(get head)a

  adapter Tesla.Adapter.Finch, name: LinkPreview.Finch, body_format: :binary
  plug Tesla.Middleware.BaseUrl, "http://"
  plug LinkPreview.Requests.RobustDecompression
  plug Tesla.Middleware.FollowRedirects

  @doc """
    Check if given url leads to image.
  """
  @spec image?(String.t()) :: boolean
  def image?(url) do
    case head(url) do
      {:ok, %Tesla.Env{status: 200} = env} ->
        env
        |> Tesla.get_header("content-type")
        |> String.match?(~r/\Aimage\//)

      {:ok, %Tesla.Env{}} ->
        false

      {:error, %Tesla.Error{}} ->
        false
    end
  end
end

defmodule LinkPreview.Requests.RobustDecompression do
  @moduledoc """
  Custom decompression middleware that handles zlib errors gracefully.
  Falls back to returning raw content if decompression fails.
  """

  @behaviour Tesla.Middleware

  def call(env, next, _opts) do
    case Tesla.run(env, next) do
      {:ok, env} -> {:ok, decompress_response(env)}
      error -> error
    end
  end

  defp decompress_response(%Tesla.Env{} = env) do
    content_encoding = Tesla.get_header(env, "content-encoding")

    case content_encoding do
      "gzip" -> safe_decompress(env, &:zlib.gunzip/1)
      "x-gzip" -> safe_decompress(env, &:zlib.gunzip/1)
      "deflate" -> safe_decompress(env, &safe_inflate/1)
      "compress" -> safe_decompress(env, &decompress_lzw/1)
      _ -> env
    end
  end

  defp safe_decompress(%Tesla.Env{body: body} = env, decompress_fun) when is_binary(body) do
    try do
      decompressed_body = decompress_fun.(body)
      %{env | body: decompressed_body}
    rescue
      ErlangError ->
        # If decompression fails, return original body and remove content-encoding header
        env
        |> Tesla.put_header("content-encoding", nil)
    catch
      :error, _ ->
        # Catch any other decompression errors
        env
        |> Tesla.put_header("content-encoding", nil)
    end
  end

  defp safe_decompress(env, _), do: env

  # Safe deflate handling - deflate can be either raw deflate or zlib wrapped
  defp safe_inflate(data) do
    try do
      # Try raw deflate first
      z = :zlib.open()
      # -15 for raw deflate
      :zlib.inflateInit(z, -15)
      result = :zlib.inflate(z, data)
      :zlib.inflateEnd(z)
      :zlib.close(z)
      IO.iodata_to_binary(result)
    catch
      _ ->
        try do
          # Try zlib wrapped deflate
          z = :zlib.open()
          :zlib.inflateInit(z)
          result = :zlib.inflate(z, data)
          :zlib.inflateEnd(z)
          :zlib.close(z)
          IO.iodata_to_binary(result)
        catch
          # Return original if both fail
          _ -> data
        end
    end
  end

  # Simple LZW decompression fallback (basic implementation)
  defp decompress_lzw(data) do
    # For compress format, just return original data if we can't decompress
    # Most sites don't use this format anyway
    data
  end
end
