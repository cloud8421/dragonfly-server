defmodule RunnerTest do
  use ExUnit.Case

  test "processes a job payload" do
    payload = "W1siZiIsImF0dGFjaG1lbnRzLzIwMTQwMTIzVDE3NTc0NS0yODIzL1VudGl0bGVkLnBuZyJdLFsicCIsImNvbnZlcnQiLCItdGh1bWJuYWlsIDI3M3gyNzNeXiAtZ3Jhdml0eSBjZW50ZXIgLWNyb3AgMjczeDI3MyswKzAgK3JlcGFnZSAtZHJhdyAncG9seWdvbiAwLDAgMjczLDI3MyAyNzMsMCBmaWxsIG5vbmUgbWF0dGUgMTM1LDEzNSBmbG9vZGZpbGwnIiwicG5nIl1d"
    expected = [fetch: "attachments/20140123T175745-2823/Untitled.png",
      shell: "convert - -thumbnail 273x273^^ -gravity center -crop 273x273+0+0 +repage -draw 'polygon 0,0 273,273 273,0 fill none matte 135,135 floodfill'",
      format: "jpg"]
    assert(expected == Runner.process(payload))
  end
end
