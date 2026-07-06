defmodule DtsBuddy.BackendTest do
  use ExUnit.Case, async: true

  alias DtsBuddy.Backend

  describe "name validation guards filesystem access" do
    test "compile/2 rejects an unsafe name before writing anything" do
      assert {:error, {:invalid_name, "../evil"}} = Backend.compile("/dts-v1/;", "../evil")
    end

    test "load/1 rejects an unsafe name before creating any directory" do
      assert {:error, {:invalid_name, "nested/name"}} =
               Backend.load({:ok, "/nonexistent.dtbo", "nested/name"})
    end

    test "load/1 passes through an upstream compilation error" do
      assert {:error, :boom} = Backend.load({:error, :boom})
    end
  end
end
