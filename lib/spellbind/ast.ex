defmodule Spellbind.AST do
  @moduledoc """
  AST representation and typespecs for a simple lambda calculus interpreter.
  """

  alias Spellbind.Lexer

  @typedoc """
  Represents a variable or identifier

  ## Examples

  x -> `{:variable, "x"}`
  """
  @type v :: {:variable, String.t()}
  @typedoc """
  Represents an Abstraction, that holds an parameter and a body

  ## Examples

  λx.x -> `{:abstraction, "x", {:variable, "x"}}`
  """
  @type abs :: {:abstraction, String.t(), exp}
  @typedoc """
  Represents an Application that holds the function to be applied
  and the argument to that function

  ## Examples

  (f x) -> `{:application, {:variable, "f"}, {:variable, "x"}}`
  (λx.x) y -> `{:application, {:abstraction, "x", {:variable, "x"}}, {:variable, "y"}}`
  """
  @type app :: {:application, exp, exp}

  @typedoc """
  Represents a general Expression
  """
  @type exp :: v | abs | app

  @typedoc ""
  @type t :: exp | list(exp)

  @spec parse(list(Lexer.token())) :: {:ok, t} | {:error, term}
  def parse(tokens) do
    with {:ok, ast, []} <- parse_expression(tokens) do
      {:ok, ast}
    end
  end

  defp parse_expression(tokens) do
    with {:ok, left, rest} <- parse_atom(tokens) do
      parse_application(left, rest)
    end
  end

  defp parse_atom([]), do: {:error, :unexpected_end_of_input}

  defp parse_atom([:lambda | rest]) do
    parse_abstraction(rest)
  end

  defp parse_atom([:lparen | rest]) do
    with {:ok, exp, [:rparen | rem]} <- parse_expression(rest) do
      {:ok, exp, rem}
    else
      {:error, _} = err -> err
      _ -> {:error, :missing_closing_paren}
    end
  end

  defp parse_atom([{:identifier, x} | rest]) do
    {:ok, {:variable, x}, rest}
  end

  defp parse_atom([token | _rest]) do
    {:error, {:unexpected_token, token}}
  end

  defp parse_application(left, tokens) do
    case parse_atom(tokens) do
      {:ok, right, rest} ->
        {:application, left, right}
        |> parse_application(rest)

      {:error, _reason} ->
        {:ok, left, tokens}
    end
  end

  defp parse_abstraction([{:identifier, x}, :dot | rest]) do
    with {:ok, body, rem} <- parse_expression(rest) do
      {:ok, {:abstraction, x, body}, rem}
    end
  end

  defp parse_abstraction([{:identifier, _var} | rest]) do
    {:error, {:expected_dot, rest}}
  end

  defp parse_abstraction([token | _rest]) do
    {:error, {:expected_identifier, token}}
  end

  defp parse_abstraction([]) do
    {:error, :unexpected_end_of_input}
  end
end
