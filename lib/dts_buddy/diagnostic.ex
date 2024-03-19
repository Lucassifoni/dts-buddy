defmodule DtsBuddy.Diagnostic do
  @moduledoc """
  Runs an overlay through the compilation and loading cycle, then proceeds to check
  if there really is the expected outcome on the header.

  To run a diagnostic cycle, you should call run_diagnostic/1, passing a reader function
  as an argument. This is so that we do not directly depend on Circuits.GPIO as this is
  not strictly needed to use DtsBuddy.

  Example use, succeeding :

      iex> {:ok, gpio} = Circuits.GPIO.open("GPIO12", :input)
      {:ok, %Circuits.GPIO.CDev{}}
      iex> reader = fn () -> Circuits.GPIO.read(gpio)
      #Function<>
      iex> DtsBuddy.Diagnostic.run_diagnostic(reader)
      [DtsBuddy.Diagnostic] Running system checks
      [DtsBuddy.Diagnostic] All system checks passed
      [DtsBuddy.Diagnostic] Loading a sample overlay
      [DtsBuddy.Diagnostic] Sampling GPIO with the user-supplied reader function for ~5 seconds
      [DtsBuddy.Diagnostic] Behavior of the activated GPIO looks correct with 5 LOW samples and 5 HIGH samples
      [DtsBuddy.Diagnostic] Unloading overlay testled
      [DtsBuddy.Diagnostic] Everything looks OK
      :ok

  Example use, failing :

      iex> {:ok, gpio} = Circuits.GPIO.open("GPIO12", :input)
      {:ok, %Circuits.GPIO.CDev{}}
      iex> reader = fn () -> Circuits.GPIO.read(gpio)
      #Function<>
      iex> DtsBuddy.Diagnostic.run_diagnostic(reader)
      [DtsBuddy.Diagnostic] Running system checks
      [DtsBuddy.Diagnostic] Device tree compiler is missing on the system.
      [DtsBuddy.Diagnostic] All tests did not pass. Please refer to the above logs for further details.
      :error
  """

  @doc false
  @spec log(any()) :: :ok
  def log(msg) do
    IO.puts("[DtsBuddy.Diagnostic] #{msg}")
  end

  @doc false
  @spec run_diagnostic() :: :ok
  def run_diagnostic do
    IO.puts("""
    DtsBuddy.Diagnostic.run_diagnostic/0 is a placeholder. You should call
    DtsBuddy.Diagnostic.run_diagnostic/1, passing a reader function as
    the first argument of this function.

    The reader function should read an input GPIO physically connected to GPIO 36 which is used as a LED device.
    The reader function should return 0 or 1 to indicate the GPIO pin being high or low.
    The test DTS should generate an 1Hz square wave on GPIO 36.
    We grossly check that the pin toggles a few times in five seconds, by roughly sampling every 100ms with sleeping tasks.
    """)
  end

  @doc false
  @spec run_diagnostic(fun()) :: :error | :ok
  def run_diagnostic(reader_fn) do
    with :ok <- run_system_checks(),
         {:ok, _, name} = compilation_result <- compile_sample(),
         :ok <- DtsBuddy.load(compilation_result),
         samples <- gather_samples(reader_fn),
         :ok <- valid_samples(samples),
         :ok <- unload(name) do
      log("Everything looks OK.")
      :ok
    else
      _ ->
        log("All tests did not pass. Please refer to the above logs for further details.")
        :error
    end
  end

  @doc false
  @spec unload(binary()) :: :error | :ok
  def unload(name) do
    log("Unloading overlay #{name}")
    DtsBuddy.unload(name)

    case DtsBuddy.status(name) do
      :applied ->
        log("Unloading overlay #{name} failed")
        :error

      _ ->
        :ok
    end
  end

  @doc """
  Checks if the samples collected by the reader function look correct, in the sense that there was enough variation
  of output in the given time. An erratic GPIO would currently look correct if it was checked by this function though.
  """
  @spec valid_samples(any()) :: :error | :ok
  def valid_samples(samples) do
    keyed = Enum.frequencies(samples)

    case keyed do
      %{0 => n0, 1 => n1} when n0 > 5 and n1 > 5 ->
        log(
          "Behavior of the activated GPIO looks correct with #{n0} LOW samples and #{n1} HIGH samples"
        )

        :ok

      _ ->
        log("Behavior of the activated GPIO looks incorrect. Samples : #{inspect(keyed)}")
        :error
    end
  end

  @doc """
  Gathers samples to check the actual behavior of the LED overlay by sampling GPIO roughly every 100ms.
  Output should be a list of 1 and 0s.
  """
  @spec gather_samples(fun()) :: list(integer())
  def gather_samples(reader_fn) do
    log("Sampling GPIO with the user-supplied reader function for ~5 seconds")

    Task.await_many(
      Enum.map(0..50, fn i ->
        Process.sleep(i * 100)
        reader_fn.()
      end),
      10_000
    )
  end

  @doc false
  @spec run_system_checks() :: :error | :ok
  def run_system_checks do
    log("Running system checks")

    case DtsBuddy.Backend.checks() do
      [overlays_enabled: true, device_tree_compiler_present: true] ->
        log("All system checks passed")
        :ok

      [overlays_enabled: _, device_tree_compiler_present: false] ->
        log("Device tree compiler is missing on the system.")
        :error

      [overlays_enabled: false, device_tree_compiler_present: true] ->
        log("ConfigFS seems disabled on the system")
        :error
    end
  end

  @doc false
  @spec compile_sample() :: {:error, {any(), pos_integer()}} | {:ok, binary(), binary()}
  def compile_sample do
    import DtsBuddy.Sigil
    log("Loading a sample overlay")

    ~DTS"""
    /dts-v1/;
    /plugin/;

    /* Compile:
        dtc -@ -I dts -O dtb -o gpio_led.dtbo gpio_led.dts
    */

    &{/} {
        gpios_leds {
            compatible = "gpio-leds";
            test_led@36 {
                label = "test-led-gpio36";
                gpios = <&pio 1 4 0>; /* GPIO36/PB4 */

                /* Blink LED at 1 Hz (500 ms on, off) */
                linux,default-trigger = "pattern";
                led-pattern = <1 500 1 0 0 500 0 0>;
            };
        };
    };
    """testled
  end
end
