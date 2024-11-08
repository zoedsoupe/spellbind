defmodule Spellbind.Lexer do
  @moduledoc "Lexer for the lambda calculus parser."

  @type token ::
          :lambda
          | :dot
          | :lparen
          | :rparen
          | {:identifier, String.t()}
          | {:invalid_char, String.t()}

  defguardp is_ws(c) when c in [?\s, ?\n, ?\t, ?\r]

  defguardp is_alpha(c) when c in ?A..?z

  defguard is_num(c) when c in ?0..?9

  defguardp is_alpha_num(c) when is_alpha(c) or is_num(c) or c == ?_

  @spec tokenize(String.t()) :: {:ok, list(token)} | {:error, term}
  def tokenize(input) when is_binary(input) do
    input
    |> String.trim()
    |> tokenize([])
  end

  defp tokenize(<<>>, []), do: {:error, :empty}
  defp tokenize(<<>>, t), do: {:ok, Enum.reverse(t)}

  defp tokenize(<<c::utf8, rest::binary>>, t) when is_ws(c) do
    rest
    |> String.trim_leading()
    |> tokenize(t)
  end

  defp tokenize(<<?\\, rest::binary>>, tokens) do
    tokenize(rest, [:lambda | tokens])
  end

  defp tokenize(<<"λ", rest::binary>>, tokens) do
    tokenize(rest, [:lambda | tokens])
  end

  defp tokenize(<<?., rest::binary>>, tokens) do
    tokenize(rest, [:dot | tokens])
  end

  defp tokenize(<<?(, rest::binary>>, tokens) do
    tokenize(rest, [:lparen | tokens])
  end

  defp tokenize(<<?), rest::binary>>, tokens) do
    tokenize(rest, [:rparen | tokens])
  end

  defp tokenize(<<char::utf8, rest::binary>>, tokens) when is_alpha(char) do
    {identifier, rest} = read_identifier(<<char::utf8, rest::binary>>)
    tokenize(rest, [{:identifier, identifier} | tokens])
  end

  defp tokenize(<<char::utf8, _rest::binary>>, _tokens) do
    {:error, {:invalid_character, <<char::utf8>>}}
  end

  defp read_identifier(<<char::utf8, rest::binary>>) when is_alpha_num(char) do
    {identifier_rest, remaining} = read_identifier(rest)
    {<<char::utf8>> <> identifier_rest, remaining}
  end

  defp read_identifier(rest), do: {"", rest}
end
