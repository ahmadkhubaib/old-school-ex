defmodule Adjust.Application do
  use Application

  alias Adjust.Endpoint
  alias Adjust.DB

  def start(_type, _args),
    do: Supervisor.start_link(children(), opts())

    defp children do
      [
        Endpoint,
        DB
      ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: Adjust.Supervisor
    ]
  end
end