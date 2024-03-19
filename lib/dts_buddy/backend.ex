defmodule DtsBuddy.Backend do
  @moduledoc """
  Collection of functions that actually check system status, compile DTS files,
  check overlay status.
  """
  alias DtsBuddy.Paths

  @doc """
  Calls `mount -t configfs none /sys/kernel/config`.
  """
  @spec enable_overlays() :: :ok | {:error, {any(), pos_integer()}}
  def enable_overlays do
    case System.cmd("mount", ["-t", "configfs", "none", Paths.config_dir()]) do
      {_, 0} -> :ok
      e -> {:error, e}
    end
  end

  @doc """
  Checks the presence of the `dtc` binary.
  """
  @spec device_tree_compiler_present?() :: boolean()
  def device_tree_compiler_present?, do: !is_nil(System.find_executable("dtc"))

  @doc """
  Checks the presence of the /sys/kernel/config/device-tree/overlays directory.
  """
  @spec overlays_enabled?() :: boolean()
  def overlays_enabled?, do: File.exists?(Paths.overlays_dir())

  @doc """
  Helper to display all system checks. Quite frugal for now, but should be extended.
  """
  @spec checks() :: [
          {:device_tree_compiler_present, boolean()} | {:overlays_enabled, boolean()}
        ]
  def checks do
    [
      overlays_enabled: overlays_enabled?(),
      device_tree_compiler_present: device_tree_compiler_present?()
    ]
  end

  @doc """
  Loads an overlay. This function is meant to be directly called with the
  output of DtsBuddy.compile/2 or DtsBuddy.compile_eex/3, that is, a tuple
  of the form `{:error, term()}` or `{:ok, path, name}` where path is the
  location of the compiled dtbo file, and name is the desired overlay name.
  """
  @spec load({:error, any} | {:ok, binary(), binary()}) :: {:error, any()} | :ok
  def load({:ok, path, name}), do: do_load(path, name)
  def load({:error, e}), do: {:error, e}

  @doc """
  Unloads an overlay. This should be used in a managed way as overlays must be
  unloaded in-order in a LIFO way. That is, the last applied overlay must be the
  first to be un-applied.
  If you wish to unload the third-topmost loaded overlay, while keeping the two
  that follow, you should unapply three overlays, then re-apply the last two.
  DtsBuddy.OverlayManager will help with that.
  """
  @spec unload(binary()) :: :ok | {:error, any()}
  def unload(name) do
    File.rm(Paths.overlay_dir(name))
  end

  @spec do_load(binary(), binary()) :: :ok | {:error, any()}
  defp do_load(path, name) do
    dir = Paths.overlay_dir(name)
    :ok = File.mkdir(dir)
    dtbo_path = Paths.dtbo_dir(name)
    File.write(dtbo_path, File.read!(path))
  end

  @doc """
  Reads /sys/kernel/config/device-tree/overlays/<name>/status and gives the result
  as `:applied` or `:unapplied`.
  """
  @spec status(binary()) :: :applied | :unapplied
  def status(name) do
    case File.read(Paths.status_dir(name)) do
      {:ok, "applied" <> _} -> :applied
      _ -> :unapplied
    end
  end

  @doc """
  Injects an EEx template and compiles it.
  """
  @spec compile_eex(binary(), keyword(), binary()) ::
          {:error, {any(), pos_integer()}}
          | {:ok, binary(), binary()}
  def compile_eex(str, bindings, name) do
    dts_string = EEx.eval_string(str, bindings)
    compile(dts_string, "#{name}")
  end

  @spec do_compile(binary(), binary()) :: :ok | {:error, any()}
  defp do_compile(dts, dtbo) do
    case System.cmd("dtc", [
           "-@",
           "-I",
           "dts",
           "-O",
           "dtb",
           "-o",
           dtbo,
           dts
         ]) do
      {_, 0} -> :ok
      e -> {:error, e}
    end
  end

  @doc """
  Compiles a static DTS string to the given name.
  Files written are /data/<name>.dts and /data/<name>.dtbo.
  """
  @_todo """
  Validate the overlay name since it will be used in directory paths.
  If invalid, provide an helpful error to the user.
  """
  @spec compile(binary(), binary()) ::
          {:error, any()}
          | {:ok, binary(), binary()}
  def compile(dts_string, name) do
    dts_file = Paths.dts_file_path(name)
    dtbo_file = Paths.dtbo_file_path(name)

    with {_, :ok} <- {:write, File.write(dts_file, dts_string)},
         {_, :ok} <- {:compile, do_compile(dts_file, dtbo_file)} do
      {:ok, dtbo_file, name}
    else
      {:write, _} -> {:error, "Writing the DTS file failed. Please verify the name provided."}
      {:compile, e} -> {:error, {"Compiling the DTS file failed. Here is output from DTC :", e}}
    end
  end
end
