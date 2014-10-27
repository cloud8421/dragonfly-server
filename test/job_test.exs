defmodule JobTest do
  use ExUnit.Case

  test "creates a command from job payload" do
    payload = "W1siZiIsImF0dGFjaG1lbnRzLzIwMTQwMTIzVDE3NTc0NS0yODIzL1VudGl0bGVkLnBuZyJdLFsicCIsImNvbnZlcnQiLCItdGh1bWJuYWlsIDI3M3gyNzNeXiAtZ3Jhdml0eSBjZW50ZXIgLWNyb3AgMjczeDI3MyswKzAgK3JlcGFnZSAtZHJhdyAncG9seWdvbiAwLDAgMjczLDI3MyAyNzMsMCBmaWxsIG5vbmUgbWF0dGUgMTM1LDEzNSBmbG9vZGZpbGwnIiwicG5nIl1d"
    expected = %{fetch: "#{System.get_env("HTTP_HOST")}/attachments/20140123T175745-2823/Untitled.png",
      shell: "/usr/local/bin/convert - -thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill' -strip png:-",
      format: "png"}
    assert(expected == Job.to_command(payload))
  end

  test "supports a fetch only operation" do
    payload = "W1siZiIsImF0dGFjaG1lbnRzLzIwMTQxMDIwVDA4NTY1Ny03ODMxL1NhaW5zYnVyeSdzIFNwb29reSBTcGVha2VyIC0gaW1hZ2UgMS5qcGciXV0"
    expected = %{fetch: "#{System.get_env("HTTP_HOST")}/attachments/20141020T085657-7831/Sainsbury's Spooky Speaker - image 1.jpg"}
    assert(expected == Job.to_command(payload))
  end

  test "supports local files" do
    payload = "W1siZmYiLCIvYXBwL2FwcC9hc3NldHMvaW1hZ2VzL2RlZmF1bHRfYXJ0aWNsZV9pbWFnZS5wbmciXSxbInAiLCJ0aHVtYiIsIjEwMHgxMDAjIl0sWyJlIiwianBnIl1d"
    expected = %{file: "/app/app/assets/images/default_article_image.png", format: "jpg", shell: "/usr/local/bin/convert - -thumbnail 100x100# -strip jpg:-"}
    assert(expected == Job.to_command(payload))
  end
end
