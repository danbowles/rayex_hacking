defmodule RayexHacking.Game do
  alias Rayex.Structs, as: RS
  use GenServer
  use Rayex

  # Config
  @fps 60
  @width 800
  @height 450
  @title "Rayex Hacking"
  # Colors
  @color_green_a %RS.Color{r: 0, g: 100, b: 48, a: 126}
  @color_gray %RS.Color{r: 0, g: 0, b: 0, a: 255}

  defmodule State do
    defstruct ball_pos: {400, 225},
              ball_speed: {4, 5},
              ball_radius: 20.0
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    IO.inspect("Starting Rayex Hacking Application")
    init_window(@width, @height, @title)
    set_target_fps(@fps)

    tick(%State{})

    {:ok, %State{}}
  end

  def tick(state) do
    if window_should_close() do
      close_window()
      System.stop(0)
      {:stop, :normal, state}
    else
      new_state = update_game(state)

      begin_drawing()
      clear_background(@color_green_a)

      {x, y} = new_state.ball_pos
      draw_circle(trunc(x), trunc(y), new_state.ball_radius, @color_gray)
      draw_text("Rayex Hacking", 10, 10, 20, @color_gray)
      draw_fps(10, @height - 24)

      end_drawing()
      tick(new_state)
    end
  end

  # Game Logic
  defp update_game(state) do
    {x, y} = state.ball_pos
    {dx, dy} = state.ball_speed

    new_x = x + dx
    new_y = y + dy

    # Check for collision with walls
    {new_dx, new_x} =
      bounce(new_x, @width, dx, state.ball_radius)

    {new_dy, new_y} =
      bounce(new_y, @height, dy, state.ball_radius)

    %{state | ball_pos: {new_x, new_y}, ball_speed: {new_dx, new_dy}}
  end

  defp bounce(position, boundary, speed, radius) do
    new_position = position + speed

    cond do
      new_position > boundary - radius and speed > 0 ->
        {-speed, boundary - radius}

      new_position < radius and speed < 0 ->
        {-speed, radius}

      true ->
        {speed, new_position}
    end
  end
end
