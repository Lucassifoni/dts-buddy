searchData={"items":[{"type":"module","title":"DtsBuddy","doc":"DtsBuddy is meant to provide utilities to handle runtime loading of\ndevice tree overlays, while reducing the ceremony required by the\nconfigfs interface.","ref":"DtsBuddy.html"},{"type":"module","title":"Requirements - DtsBuddy","doc":"Nerves systems must be compiled with those options for this to work :\n\n    BR2_PACKAGE_DTC=y\n    BR2_PACKAGE_DTC_PROGRAMS=y\n    CONFIG_OF_CONFIGFS=y","ref":"DtsBuddy.html#module-requirements"},{"type":"module","title":"Usage - DtsBuddy","doc":"#","ref":"DtsBuddy.html#module-usage"},{"type":"module","title":"Enabling overlays configfs - DtsBuddy","doc":"The overlays configfs must first be enabled :\n\n    iex> DtsBuddy.enable_overlays()\n    :ok\n\nThis has the same effect as running this command (and does behind the scenes) :\n\n    System.cmd(\"mount\" , [\"-t\", \"configfs\", \"none\", \"/sys/kernel/config\"])\n\n#","ref":"DtsBuddy.html#module-enabling-overlays-configfs"},{"type":"module","title":"Checking if overlays are enabled - DtsBuddy","doc":"iex> DtsBuddy.overlays_enabled?()\n    true\n\n#","ref":"DtsBuddy.html#module-checking-if-overlays-are-enabled"},{"type":"module","title":"Compiling a DTS source - DtsBuddy","doc":"If your source is fully static, you can either call `DtsBuddy.compile/2` or use\nthe sigil provided by `DtsBuddy.Sigil`. The source of the following examples was\nprovided by Frank Hunleth.\n\n    iex> import DtsBuddy.Sigil\n        \n    iex> ~DTS\"\"\"\n        /dts-v1/;\n        /plugin/;\n        &{/} {\n        gpios_leds {\n            compatible = \"gpio-leds\";\n            test_led@36 {\n            label = \"test-led-gpio36\";\n            gpios = <&pio 1 4 0>; /* GPIO36/PB4 */\n            /* Blink LED at 1 Hz (500 ms on, off) */\n            linux,default-trigger = \"pattern\";\n            led-pattern = <1 500 1 0 0 500 0 0>;\n            };\n        };\n        };\n    \"\"\"test_led  \n\n    {:ok, \"/data/test_led.dtbo\", \"test_led\"}\n\n\nYou should provide both the heredoc contents (inside triple quotes) and modifiers\n(after the heredoc closes, here \"test_led\"). We use the modifiers as the overlay\nname later.\n\nUsing the sigil is strictly equivalent to calling `DtsBuddy.compile/2`.\n`DtsBuddy` does not immediately load this overlay.\n\nIf your source is not static, you can either manually build it to call `DtsBuddy.compile/2`,\nor use `DtsBuddy.compile_eex/3` to use an EEX template string.\n\n#","ref":"DtsBuddy.html#module-compiling-a-dts-source"},{"type":"module","title":"Loading an overlay - DtsBuddy","doc":"The DtsBuddy.load function is thought to use the compilation result coming from either\n`DtsBuddy.compile/2` or `DtsBuddy.compile_eex/3` directly, that is, a tuple having\nthe form `{:ok, dtbo_file, name}`.\n\nLoading the overlay with the name   will create the directory `/sys/kernel/config/device-tree/overlays/ `,\nand write the contents of the compiled dtbo file to `/sys/kernel/config/device-tree/overlays/ /dtbo`.\n\nAfter loading an overlay, calling `DtsBuddy.status/1` with the overlay name should return `:applied`.","ref":"DtsBuddy.html#module-loading-an-overlay"},{"type":"function","title":"DtsBuddy.compile/2","doc":"","ref":"DtsBuddy.html#compile/2"},{"type":"function","title":"DtsBuddy.compile_eex/3","doc":"","ref":"DtsBuddy.html#compile_eex/3"},{"type":"function","title":"DtsBuddy.enable_overlays/0","doc":"","ref":"DtsBuddy.html#enable_overlays/0"},{"type":"function","title":"DtsBuddy.load/1","doc":"","ref":"DtsBuddy.html#load/1"},{"type":"function","title":"DtsBuddy.overlays_enabled?/0","doc":"","ref":"DtsBuddy.html#overlays_enabled?/0"},{"type":"function","title":"DtsBuddy.status/1","doc":"","ref":"DtsBuddy.html#status/1"},{"type":"module","title":"DtsBuddy.Backend","doc":"Collection of functions that actually check system status, compile DTS files,\ncheck overlay status.","ref":"DtsBuddy.Backend.html"},{"type":"function","title":"DtsBuddy.Backend.checks/0","doc":"Helper to display all system checks. Quite frugal for now, but should be extended.","ref":"DtsBuddy.Backend.html#checks/0"},{"type":"function","title":"DtsBuddy.Backend.compile/2","doc":"Compiles a static DTS string to the given name.\nFiles written are /data/ .dts and /data/ .dtbo.","ref":"DtsBuddy.Backend.html#compile/2"},{"type":"function","title":"DtsBuddy.Backend.compile_eex/3","doc":"Injects an EEx template and compiles it.","ref":"DtsBuddy.Backend.html#compile_eex/3"},{"type":"function","title":"DtsBuddy.Backend.device_tree_compiler_present?/0","doc":"Checks the presence of the `dtc` binary.","ref":"DtsBuddy.Backend.html#device_tree_compiler_present?/0"},{"type":"function","title":"DtsBuddy.Backend.enable_overlays/0","doc":"Calls `mount -t configfs none /sys/kernel/config`.","ref":"DtsBuddy.Backend.html#enable_overlays/0"},{"type":"function","title":"DtsBuddy.Backend.load/1","doc":"Loads an overlay. This function is meant to be directly called with the\noutput of DtsBuddy.compile/2 or DtsBuddy.compile_eex/3, that is, a tuple\nof the form `{:error, term()}` or {:ok, path, name}` where path is the\nlocation of the compiled dtbo file, and name is the desired overlay name.","ref":"DtsBuddy.Backend.html#load/1"},{"type":"function","title":"DtsBuddy.Backend.overlays_enabled?/0","doc":"Checks the presence of the /sys/kernel/config/device-tree/overlays directory.","ref":"DtsBuddy.Backend.html#overlays_enabled?/0"},{"type":"function","title":"DtsBuddy.Backend.status/1","doc":"Reads /sys/kernel/config/device-tree/overlays/ /status and gives the result\nas `:applied` or `:unapplied`.","ref":"DtsBuddy.Backend.html#status/1"},{"type":"module","title":"DtsBuddy.Paths","doc":"Helper module to remove paths juggling out of DtsBuddy.Backend","ref":"DtsBuddy.Paths.html"},{"type":"function","title":"DtsBuddy.Paths.config_dir/0","doc":"Configfs directory.","ref":"DtsBuddy.Paths.html#config_dir/0"},{"type":"function","title":"DtsBuddy.Paths.dtbo_dir/1","doc":"DTBO directory for a given","ref":"DtsBuddy.Paths.html#dtbo_dir/1"},{"type":"function","title":"DtsBuddy.Paths.dtbo_file_path/1","doc":"Location of the DTBO file to be written for the given  .","ref":"DtsBuddy.Paths.html#dtbo_file_path/1"},{"type":"function","title":"DtsBuddy.Paths.dts_file_path/1","doc":"Location of the DTS file to be written for the given  .","ref":"DtsBuddy.Paths.html#dts_file_path/1"},{"type":"function","title":"DtsBuddy.Paths.overlay_dir/1","doc":"Overlay directory for a given","ref":"DtsBuddy.Paths.html#overlay_dir/1"},{"type":"function","title":"DtsBuddy.Paths.overlays_dir/0","doc":"Overlays directory.","ref":"DtsBuddy.Paths.html#overlays_dir/0"},{"type":"function","title":"DtsBuddy.Paths.status_dir/1","doc":"Status file path for a given","ref":"DtsBuddy.Paths.html#status_dir/1"},{"type":"function","title":"DtsBuddy.Paths.writable_path/1","doc":"Location of a writable directory for the given  . Should be\nconfigurable by the user as people maybe have configurations\ndiverging from the common nerves convention to have /data writable ?","ref":"DtsBuddy.Paths.html#writable_path/1"},{"type":"module","title":"DtsBuddy.Sigil","doc":"Sigil form for DtsBuddy, allowing lighter syntax to compile an overlay.","ref":"DtsBuddy.Sigil.html"},{"type":"function","title":"DtsBuddy.Sigil.sigil_DTS/2","doc":"","ref":"DtsBuddy.Sigil.html#sigil_DTS/2"}],"content_type":"text/markdown"}