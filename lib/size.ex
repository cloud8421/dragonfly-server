defmodule Size do
  @resize_geometry ~r/\A\d*x\d*[><%^!]?\z|\A\d+@\z/
  @crop_geometry ~r/\A(\d+)x(\d+)([+-]\d+)?([+-]\d+)?(\w{1,2})?\z/
  @cropped_resize_geometry ~r/\A(\d+)x(\d+)#(\w{1,2})?\z/

  # '400x300'        resize, maintain aspect ratio
  # '400x300!'       force resize, don't maintain aspect ratio
  # '400x'           resize width, maintain aspect ratio
  # 'x300'           resize height, maintain aspect ratio
  # '400x300<'       resize only if the image is smaller than this
  # '400x300>'       resize only if the image is larger than this
  # '50x50%'         resize width and height to 50%
  # '400x300^'       resize width, height to minimum 400,300, maintain aspect ratio
  # '2000@'          resize so max area in pixels is 2000
  # '400x300#'       resize, crop if necessary to maintain aspect ratio (centre gravity)
  # '400x300#ne'     as above, north-east gravity
  # '400x300se'      crop, with south-east gravity
  # '400x300+50+100' crop from the point 50,100 with width, height 400,300

  def expand(size_string) do
    cond do
      match = Regex.run(@resize_geometry, size_string) ->
        expand_resize(match)
      match = Regex.run(@crop_geometry, size_string) ->
        expand_crop(match)
      match = Regex.run(@cropped_resize_geometry, size_string) ->
        expand_crop_resize(match)
      true -> :wtf
    end
  end

  defp expand_resize([dimensions]) do
    "-resize #{dimensions}"
  end

  defp expand_crop([_match, width, height, "", "", gravity]) do
    "-gravity #{expand_gravity(gravity)} -crop #{width}x#{height} +repage"
  end

  defp expand_crop([_match, width, height, x, y]) do
    "-crop #{width}x#{height}#{x}#{y} +repage"
  end

  defp expand_crop_resize([_match, width, height, gravity]) do
    "-resize #{width}x#{height}^^ -gravity #{expand_gravity(gravity)} -crop #{width}x#{height}+0+0 +repage"
  end

  defp expand_crop_resize([_match, width, height]) do
    "-resize #{width}x#{height}^^ -gravity center -crop #{width}x#{height}+0+0 +repage"
  end

  defp expand_gravity("nw"), do: "northwest"
  defp expand_gravity("n"), do: "north"
  defp expand_gravity("ne"), do: "northeast"
  defp expand_gravity("w"), do: "west"
  defp expand_gravity("c"), do: "center"
  defp expand_gravity("e"), do: "east"
  defp expand_gravity("sw"), do: "southwest"
  defp expand_gravity("s"), do: "south"
  defp expand_gravity("se"), do: "southeast"
end
