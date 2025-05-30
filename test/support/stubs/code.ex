defmodule LinkPreview.Test.Stubs.Code do
  def ensure_loaded?(:hackney), do: false
  def ensure_loaded?(:json), do: false
  def ensure_loaded?(Jason), do: true
  def ensure_loaded?(Poison), do: false
  def ensure_loaded?(Mogrify), do: true
  def ensure_loaded?(Temp), do: true
  def ensure_loaded?(:fuse), do: false
  def ensure_loaded?(other), do: Code.ensure_loaded?(other)
end

defmodule HtmlEntitiesNotLoaded do
  def ensure_loaded?(HtmlEntities), do: false
  def ensure_loaded?(_), do: true
end

defmodule MogrifyNotLoaded do
  def ensure_loaded?(Mogrify), do: false
  def ensure_loaded?(_), do: true
end

defmodule TempNotLoaded do
  def ensure_loaded?(Temp), do: false
  def ensure_loaded?(_), do: true
end
