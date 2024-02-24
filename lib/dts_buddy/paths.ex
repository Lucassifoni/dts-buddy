defmodule DtsBuddy.Paths do
  @moduledoc """
  Helper module to remove paths juggling out of DtsBuddy.Backend
  """

  @doc """
  Overlays directory.
  """
  @spec overlays_dir() :: binary()
  def overlays_dir, do: "/sys/kernel/config/device-tree/overlays"

  @doc """
  Configfs directory.
  """
  @spec config_dir() :: <<_::144>>
  def config_dir, do: "/sys/kernel/config"

  @doc """
  Location of the DTS file to be written for the given <name>.
  """
  @spec dts_file_path(binary()) :: binary()
  def dts_file_path(name), do: writable_path(name) <> ".dts"

  @doc """
  Location of the DTBO file to be written for the given <name>.
  """
  @spec dtbo_file_path(binary()) :: binary()
  def dtbo_file_path(name), do: writable_path(name) <> ".dtbo"

  @doc """
  Location of a writable directory for the given <name>. Should be
  configurable by the user as people maybe have configurations
  diverging from the common nerves convention to have /data writable ?
  """
  @spec writable_path(binary()) :: binary()
  def writable_path(file_name), do: Path.join("/data", file_name)

  @doc """
  Overlay directory for a given <name>
  """
  @spec overlay_dir(binary()) :: binary()
  def overlay_dir(name), do: Path.join(overlays_dir(), name)

  @doc """
  DTBO directory for a given <name>
  """
  @spec dtbo_dir(binary()) :: binary()
  def dtbo_dir(name), do: Path.join(overlay_dir(name), "dtbo")

  @doc """
  Status file path for a given <name>
  """
  @spec status_dir(binary()) :: binary()
  def status_dir(name), do: Path.join(overlay_dir(name), "status")
end
