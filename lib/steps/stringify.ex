defprotocol Steps.Stringify do
  def stringify(data)
end

defimpl Steps.Stringify, for: List do
  def stringify(list), do: list |> Enum.map_join &Steps.Stringify.stringify/1
end

defimpl Steps.Stringify, for: Map do
  def stringify(map), do: map |> Enum.sort |> Steps.Stringify.stringify
end

defimpl Steps.Stringify, for: Tuple do
  def stringify(tuple), do: tuple |> Tuple.to_list |> Steps.Stringify.stringify
end

defimpl Steps.Stringify, for: BitString do
  def stringify(string), do: string
end

defimpl Steps.Stringify, for: Atom do
  def stringify(atom), do: atom |> to_string
end

defimpl Steps.Stringify, for: Integer do
  def stringify(integer), do: integer |> to_string
end

defimpl Steps.Stringify, for: Float do
  def stringify(float), do: float |> to_string
end
