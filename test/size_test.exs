defmodule SizeTest do
  use ExUnit.Case

  test "resize and maintain aspect ratio" do
    assert("-resize 400x300" == Size.expand("400x300"))
  end

  test "resize and force ratio" do
    assert("-resize 400x300!" == Size.expand("400x300!"))
  end

  test "resize width, maintain ratio" do
    assert("-resize 400x" == Size.expand("400x"))
  end

  test "resize height, maintain ratio" do
    assert("-resize x300" == Size.expand("x300"))
  end

  test "resize only if image is smaller" do
    assert("-resize 400x300<" == Size.expand("400x300<"))
  end

  test "resize only if image is larger" do
    assert("-resize 400x300>" == Size.expand("400x300>"))
  end

  test "resize to percentage" do
    assert("-resize 50x50%" == Size.expand("50x50%"))
  end

  test "resize to minimum and keep ratio" do
    assert("-resize 400x300^" == Size.expand("400x300^"))
  end

  test "resize to a max area of x pixels" do
    assert("-resize 2000@" == Size.expand("2000@"))
  end

  test "resize and crop maintaining ratio, default gravity" do
    assert("-resize 400x300^^ -gravity center -crop 400x300+0+0 +repage" == Size.expand("400x300#"))
  end

  test "resize and crop maintaining ratio, custom gravity" do
    assert("-resize 400x300^^ -gravity northeast -crop 400x300+0+0 +repage" == Size.expand("400x300#ne"))
  end

  test "crop with gravity" do
    assert("-gravity southeast -crop 400x300 +repage" == Size.expand("400x300se"))
  end

  test "crop with coordinates and dimensions" do
    assert("-crop 400x300+50+100 +repage" == Size.expand("400x300+50+100"))
  end
end
