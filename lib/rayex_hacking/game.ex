defmodule RayexHacking.Game do
  alias Rayex.Structs, as: RS
  use GenServer
  use Rayex

  # Config
  @fps 60
  @key_enter 257
  @width 800
  @height 450
  @title "Rayex Hacking"
  @logo_timeout 180
  # Colors
  @color_white %RS.Color{r: 255, g: 255, b: 255, a: 255}
  @color_green_a %RS.Color{r: 0, g: 100, b: 48, a: 126}
  @color_gray %RS.Color{r: 0, g: 0, b: 0, a: 255}

  defmodule State do
    defstruct ball_pos: {400, 225},
              ball_speed: {4, 5},
              ball_radius: 20.0,
              game_screen: :logo,
              frame_count: 0
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
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
      begin_drawing()

      render_screen(state)
      next_state = update_game(state)

      end_drawing()

      # Tick Frame Count
      next_state = %{next_state | frame_count: next_state.frame_count + 1}
      # Tick with new state
      tick(next_state)
    end
  end

  defp render_screen(%State{game_screen: :logo, frame_count: frame_count})
       when frame_count <= @logo_timeout do
    clear_background(@color_white)
    draw_text("LOGO SCREEN", 10, 10, 20, @color_gray)
    draw_text("WAIT for 3 SECONDS...", 290, 220, 20, @color_gray)
  end

  defp render_screen(%State{game_screen: :title}) do
    clear_background(@color_white)
    draw_text("TITLE SCREEN", 10, 10, 20, @color_gray)
    draw_text("SKIP with [ENTER]", 290, 220, 20, @color_gray)
  end

  defp render_screen(%State{game_screen: :game} = state) do
    clear_background(@color_green_a)

    {x, y} = state.ball_pos
    draw_circle(trunc(x), trunc(y), state.ball_radius, @color_gray)
    draw_text("Rayex Hacking", 10, 10, 20, @color_gray)
    draw_fps(10, @height - 24)
  end

  defp render_screen(%State{game_screen: :credits}) do
    IO.inspect("Rendering Credits Screen")
  end

  # Game Logic
  defp update_game(%{game_screen: :logo} = state) do
    # Update the game screen to title after the logo timeout
    if state.frame_count >= @logo_timeout do
      %{state | game_screen: :title, frame_count: 0}
    else
      state
    end
  end

  defp update_game(%{game_screen: :title} = state) do
    case is_key_pressed?(@key_enter) do
      true ->
        # Update the game screen to game
        %{state | game_screen: :game}

      false ->
        # Do nothing, stay on title screen
        state
    end
  end

  defp update_game(%{game_screen: :game} = state) do
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
