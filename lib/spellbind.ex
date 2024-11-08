defmodule Spellbind do
  @moduledoc false

  alias Spellbind.AST
  alias Spellbind.Lexer

  @spec parse(String.t()) :: {:ok, AST.t()} | {:error, term}
  def parse(input) when is_binary(input) do
    with {:ok, tokens} <- Lexer.tokenize(input) do
      AST.parse(tokens)
    end
  end
end
