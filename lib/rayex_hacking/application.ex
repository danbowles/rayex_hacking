defmodule RayexHacking.Application do
  use Application

  @impl true
  def start(_type, _args) do
    # RayexHacking.Game.run()
    IO.inspect("Starting Rayex Hacking Application")

    # children = [
    #   RayexHacking.Game
    # ]

    # opts = [strategy: :one_for_one, name: RayexHacking.Supervisor]
    # Supervisor.start_link(children, opts)

    {:ok, _pid} = RayexHacking.Game.start_link([])
    Process.sleep(:infinity)
  end
end
