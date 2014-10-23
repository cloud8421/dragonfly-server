defmodule PayloadTest do
  use ExUnit.Case

  test "deserializes correctly" do
    payload = "W1siZiIsImF0dGFjaG1lbnRzLzIwMTQwMTIzVDE3NTc0NS0yODIzL1VudGl0bGVkLnBuZyJdLFsicCIsImNvbnZlcnQiLCItdGh1bWJuYWlsIDI3M3gyNzNeXiAtZ3Jhdml0eSBjZW50ZXIgLWNyb3AgMjczeDI3MyswKzAgK3JlcGFnZSAtZHJhdyAncG9seWdvbiAwLDAgMjczLDI3MyAyNzMsMCBmaWxsIG5vbmUgbWF0dGUgMTM1LDEzNSBmbG9vZGZpbGwnIiwicG5nIl1d"
    steps = [["f", "attachments/20140123T175745-2823/Untitled.png"],
             ["p", "convert", "-thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill'", "png"]]
    assert(steps == Payload.decode(payload))
  end

  test "pads when needed" do
    payload = "W1siZiIsImF0dGFjaG1lbnRzLzIwMTQxMDAyVDE1MjEzMi0yODUvVW50aXRsZWQuanBnIl0sWyJwIiwidGh1bWIiLCI4OTJ4MzIwIyJdLFsiZSIsImpwZyJdXQ"
    steps = [["f", "attachments/20141002T152132-285/Untitled.jpg"],
             ["p", "thumb", "892x320#"],
             ["e", "jpg"]]
    assert(steps == Payload.decode(payload))
  end

  test "some more padding" do
    payload = "W1siZiIsImF0dGFjaG1lbnRzLzIwMTQxMDIwVDA4NTY1Ny03ODMxL1NhaW5zYnVyeSdzIFNwb29reSBTcGVha2VyIC0gaW1hZ2UgMS5qcGciXV0"
    steps = [["f", "attachments/20141020T085657-7831/Sainsbury's Spooky Speaker - image 1.jpg"]]

    assert(steps == Payload.decode(payload))
  end

end
