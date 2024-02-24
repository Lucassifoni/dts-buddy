# dts-buddy
Research on a device tree source buddy to help people compile &amp; load DTBOs at runtime in Elixir

  DtsBuddy is meant to provide utilities to handle runtime loading of
  device tree overlays, while reducing the ceremony required by the
  configfs interface.

  ## Requirements

  Nerves systems must be compiled with those options for this to work :

      BR2_PACKAGE_DTC=y
      BR2_PACKAGE_DTC_PROGRAMS=y
      CONFIG_OF_CONFIGFS=y

  ## Usage

  ### Enabling overlays configfs

  The overlays configfs must first be enabled :

      iex> DtsBuddy.enable_overlays()
      :ok

  This has the same effect as running this command (and does behind the scenes) :

      System.cmd("mount" , ["-t", "configfs", "none", "/sys/kernel/config"])

  ### Checking if overlays are enabled

      iex> DtsBuddy.overlays_enabled?()
      true

  ### Compiling a DTS source

  If your source is fully static, you can either call `DtsBuddy.compile/2` or use
  the sigil provided by `DtsBuddy.Sigil`. The source of the following examples was
  provided by Frank Hunleth.

      iex> import DtsBuddy.Sigil
          #{File.read!("sample_dt.dts")}
      {:ok, "/data/test_led.dtbo", "test_led"}


  You should provide both the heredoc contents (inside triple quotes) and modifiers
  (after the heredoc closes, here "test_led"). We use the modifiers as the overlay
  name later.

  Using the sigil is strictly equivalent to calling `DtsBuddy.compile/2`.
  `DtsBuddy` does not immediately load this overlay.

  If your source is not static, you can either manually build it to call `DtsBuddy.compile/2`,
  or use `DtsBuddy.compile_eex/3` to use an EEX template string.

  ### Loading an overlay

  The DtsBuddy.load function is thought to use the compilation result coming from either
  `DtsBuddy.compile/2` or `DtsBuddy.compile_eex/3` directly, that is, a tuple having
  the form `{:ok, dtbo_file, name}`.

  Loading the overlay with the name <name> will create the directory `/sys/kernel/config/device-tree/overlays/<name>`,
  and write the contents of the compiled dtbo file to `/sys/kernel/config/device-tree/overlays/<name>/dtbo`.

  After loading an overlay, calling `DtsBuddy.status/1` with the overlay name should return `:applied`.