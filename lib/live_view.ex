defmodule LiveView do
  defimpl Jason.Encoder, for: BSON.ObjectId do
    def encode(val, _opts \\ []) do
      val
      |> BSON.encode()
      |> Base.encode16(case: :lower)
    end
  end
  @moduledoc """
  LiveViewTodos keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
end
