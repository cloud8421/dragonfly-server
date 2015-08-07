defmodule StepsTest do
  use ExUnit.Case

  test "returns a list of commands" do
    steps = [["f", "attachments/20141002T152132-285/Untitled.jpg"],
             ["p", "convert", "-thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill'", "png"],
             ["p", "thumb", "892x320#"],
             ["e", "jpg"]]
    commands = %Steps{fetch: "#{System.get_env("HTTP_ENGINE_HOST")}/attachments/20141002T152132-285/Untitled.jpg",
                convert: "#{Config.convert_command} -'[0]' -thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill' miff:- | #{Config.convert_command} - -resize 892x320^^ -gravity center -crop 892x320+0+0 +repage -strip jpg:-",
                format: "jpg"}
    assert(commands == Steps.deserialize(steps))
  end

  test "works with remote urls" do
    steps = [["fu", "http://img.youtube.com/vi/lFaO7LDqSmk/0.jpg"],
             ["p", "convert", "-thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill'", "png"],
             ["p", "thumb", "892x320#"],
             ["e", "jpg"]]
    commands = %Steps{fetch: "http://img.youtube.com/vi/lFaO7LDqSmk/0.jpg",
                convert: "#{Config.convert_command} -'[0]' -thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill' miff:- | #{Config.convert_command} - -resize 892x320^^ -gravity center -crop 892x320+0+0 +repage -strip jpg:-",
                format: "jpg"}
    assert(commands == Steps.deserialize(steps))
  end

  test "works with local files" do
    steps = [["ff", "/app/foo.jpg"],
             ["p", "convert", "-thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill'", "png"],
             ["p", "thumb", "892x320#"],
             ["e", "jpg"]]
    commands = %Steps{file: "/app/foo.jpg",
                convert: "#{Config.convert_command} -'[0]' -thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill' miff:- | #{Config.convert_command} - -resize 892x320^^ -gravity center -crop 892x320+0+0 +repage -strip jpg:-",
                format: "jpg"}
    assert(commands == Steps.deserialize(steps))
  end

  test "understands convert options hash" do
    steps = [["ff", "/app/foo.jpg"],
             ["p", "convert", "-resize 100x100^", %{"format" => "png", "frame" => 1}]]
    commands = %Steps{file: "/app/foo.jpg",
                convert: "#{Config.convert_command} -'[1]' -resize 100x100^ -strip png:-",
                format: "png", frame: 1}
    assert(commands == Steps.deserialize(steps))
  end

  test "understands thumb options hash" do
    steps = [["ff", "/app/foo.jpg"],
             ["p", "thumb", "100x100^", %{"format" => "png", "frame" => 1}]]
    commands = %Steps{file: "/app/foo.jpg",
                convert: "#{Config.convert_command} -'[1]' -resize 100x100^ -strip png:-",
                format: "png", frame: 1}
    assert(commands == Steps.deserialize(steps))
  end

  test "reduces steps to unique string" do
    steps = [["f", "attachments/20141002T152132-285/Untitled.jpg"],
             ["p", "thumb", "892x320#", %{"frame" => 0, "format" => "jpg"}]]
    unique_string = "fattachments/20141002T152132-285/Untitled.jpgpthumb892x320#formatjpgframe0"

    assert(unique_string == Steps.to_unique_string(steps))
  end
end
