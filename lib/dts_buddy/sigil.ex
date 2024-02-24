defmodule DtsBuddy.Sigil do
  @moduledoc """
  Sigil form for DtsBuddy, allowing lighter syntax to compile an overlay.
  """
  alias DtsBuddy.Backend

  @spec sigil_DTS(binary(), charlist()) ::
          {:error, {any(), pos_integer()}}
          | {:ok, binary(), binary()}
  def sigil_DTS(dts_string, name) do
    Backend.compile(dts_string, "#{name}")
  end
end
