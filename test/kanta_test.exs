defmodule KantaTest do
  use ExUnit.Case
  doctest Kanta

  test "greets the world" do
    assert Kanta.hello() == :world
  end
end
