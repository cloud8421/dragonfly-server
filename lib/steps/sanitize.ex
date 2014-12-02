defmodule Steps.Sanitize do
  # Poor man's sanitize to avoid malicious formats:
  # anything that doesn't match will
  # cause a pattern match error, eventually crashing the worker that
  # performs the command.
  def sanitize_format("jpg"), do: "jpg"
  def sanitize_format("jpeg"), do: "jpg"
  def sanitize_format("png"), do: "png"
  def sanitize_format("gif"), do: "gif"
end
