defmodule SpellbindTest do
  use ExUnit.Case, async: true

  alias Spellbind

  describe "parse/1" do
    test "parses a variable" do
      input = "x"
      expected = {:ok, {:variable, "x"}}
      assert Spellbind.parse(input) == expected
    end

    test "parses an abstraction with variable body" do
      input = "λx.x"
      expected = {:ok, {:abstraction, "x", {:variable, "x"}}}
      assert Spellbind.parse(input) == expected
    end

    test "parses an abstraction with application body" do
      input = "λx.(x x)"
      expected = {:ok, {:abstraction, "x", {:application, {:variable, "x"}, {:variable, "x"}}}}
      assert Spellbind.parse(input) == expected
    end

    test "parses an application of two variables" do
      input = "(f x)"
      expected = {:ok, {:application, {:variable, "f"}, {:variable, "x"}}}
      assert Spellbind.parse(input) == expected
    end

    test "parses nested abstractions" do
      input = "λx.λy.x"
      expected = {:ok, {:abstraction, "x", {:abstraction, "y", {:variable, "x"}}}}
      assert Spellbind.parse(input) == expected
    end

    test "parses nested applications" do
      input = "(f (g x))"

      expected =
        {:ok,
         {:application, {:variable, "f"}, {:application, {:variable, "g"}, {:variable, "x"}}}}

      assert Spellbind.parse(input) == expected
    end

    test "parses complex expression" do
      input = "(λx.(x x)) (λx.(x x))"

      expected =
        {:ok,
         {:application, {:abstraction, "x", {:application, {:variable, "x"}, {:variable, "x"}}},
          {:abstraction, "x", {:application, {:variable, "x"}, {:variable, "x"}}}}}

      assert Spellbind.parse(input) == expected
    end

    test "returns error on missing dot in abstraction" do
      input = "λx x"
      assert {:error, _reason} = Spellbind.parse(input)
    end

    test "returns error on missing variable in abstraction" do
      input = "λ. x"
      assert {:error, _reason} = Spellbind.parse(input)
    end

    test "returns error on invalid variable name" do
      input = "λ1.x"
      assert {:error, _reason} = Spellbind.parse(input)
    end

    test "returns error on unmatched parentheses" do
      input = "(λx.x"
      assert {:error, _reason} = Spellbind.parse(input)
    end

    test "returns error on empty input" do
      input = ""
      assert {:error, _reason} = Spellbind.parse(input)
    end
  end
end
