defmodule StepsTest do
  use ExUnit.Case

  test "returns a list of commands" do
    steps = [["f", "attachments/20141002T152132-285/Untitled.jpg"],
             ["p", "convert", "-thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill'", "png"],
             ["p", "thumb", "892x320#"],
             ["e", "jpg"]]
    commands = %Steps{fetch: "#{System.get_env("HTTP_HOST")}/attachments/20141002T152132-285/Untitled.jpg",
                convert: "#{Config.convert_command} - -thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill' jpg:- | #{Config.convert_command} - -thumbnail 892x320# -strip jpg:-",
                format: "jpg"}
    assert(commands == Steps.deserialize(steps))
  end

  test "works with remote urls" do
    steps = [["fu", "http://img.youtube.com/vi/lFaO7LDqSmk/0.jpg"],
             ["p", "convert", "-thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill'", "png"],
             ["p", "thumb", "892x320#"],
             ["e", "jpg"]]
    commands = %Steps{fetch: "http://img.youtube.com/vi/lFaO7LDqSmk/0.jpg",
                convert: "#{Config.convert_command} - -thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill' jpg:- | #{Config.convert_command} - -thumbnail 892x320# -strip jpg:-",
                format: "jpg"}
    assert(commands == Steps.deserialize(steps))
  end

  test "works with local files" do
    steps = [["ff", "/app/foo.jpg"],
             ["p", "convert", "-thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill'", "png"],
             ["p", "thumb", "892x320#"],
             ["e", "jpg"]]
    commands = %Steps{file: "/app/foo.jpg",
                convert: "#{Config.convert_command} - -thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill' jpg:- | #{Config.convert_command} - -thumbnail 892x320# -strip jpg:-",
                format: "jpg"}
    assert(commands == Steps.deserialize(steps))
  end
end
