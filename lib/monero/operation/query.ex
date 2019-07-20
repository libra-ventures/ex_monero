defmodule Monero.Operation.Query do
  @moduledoc """
  Datastructure representing an operation on a Monero Daemon endpoint
  """

  defstruct action: nil,
            path: "/",
            data: %{},
            service: nil,
            parser: &Monero.Utils.identity/2

  @type t :: %__MODULE__{}
end

defimpl Monero.Operation, for: Monero.Operation.Query do
  def perform(operation, config) do
    url = Monero.Request.Url.build(operation, config)

    headers = [
      {"content-type", "application/json"}
    ]

    result = Monero.Request.request(:post, url, operation.data, headers, config, operation.service)
    parser = operation.parser

    cond do
      is_function(parser, 2) ->
        parser.(result, config)

      is_function(parser, 3) ->
        parser.(result, operation.action, config)

      true ->
        result
    end
  end

  def stream!(_, _), do: nil
end
