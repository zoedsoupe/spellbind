defmodule SpellbindTest do
  use ExUnit.Case
  doctest Spellbind

  test "greets the world" do
    assert Spellbind.hello() == :world
  end
end
