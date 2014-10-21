defmodule StepsTest do
  use ExUnit.Case

  test "returns a list of commands" do
    steps = [["f", "attachments/20141002T152132-285/Untitled.jpg"],
             ["p", "convert", "-thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill'", "png"],
             ["p", "thumb", "892x320#"],
             ["e", "jpg"]]
    commands = %{fetch: "attachments/20141002T152132-285/Untitled.jpg",
                shell: "/usr/local/bin/convert - -thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill' jpg:- | /usr/local/bin/convert - -thumbnail 892x320# jpg:-",
                format: "jpg"}
    assert(commands == Steps.to_command(steps))
  end
end
