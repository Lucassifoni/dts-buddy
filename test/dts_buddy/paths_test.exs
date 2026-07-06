defmodule DtsBuddy.PathsTest do
  use ExUnit.Case, async: true

  alias DtsBuddy.Paths

  describe "valid_name?/1" do
    test "accepts letters, digits, underscores and dashes" do
      assert Paths.valid_name?("test_led")
      assert Paths.valid_name?("led-1")
      assert Paths.valid_name?("Overlay42")
    end

    test "rejects names that could escape the target directories" do
      refute Paths.valid_name?("../escape")
      refute Paths.valid_name?("nested/name")
      refute Paths.valid_name?("with space")
      refute Paths.valid_name?("dot.name")
      refute Paths.valid_name?("")
    end

    test "rejects non-binary input" do
      refute Paths.valid_name?(nil)
      refute Paths.valid_name?(:atom)
      refute Paths.valid_name?(42)
    end
  end

  describe "path builders" do
    test "writable file paths stay under /data" do
      assert Paths.dts_file_path("led") == "/data/led.dts"
      assert Paths.dtbo_file_path("led") == "/data/led.dtbo"
    end

    test "configfs paths stay under the overlays directory" do
      assert Paths.overlay_dir("led") == "/sys/kernel/config/device-tree/overlays/led"
      assert Paths.dtbo_dir("led") == "/sys/kernel/config/device-tree/overlays/led/dtbo"
      assert Paths.status_dir("led") == "/sys/kernel/config/device-tree/overlays/led/status"
    end
  end
end
