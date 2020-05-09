defmodule Mix.Tasks.Adjust.Server do
   use Mix.Task

   @shortdoc "Start the JSON server"
   @moduledoc ~S"""
   This is used to start server so we can send Http requests to it.
   #Usage
   ```
      mix adjust.server
   ```
   This starts a local server at port `4000`
   """
   def run(_) do
      Mix.Tasks.Run.run run_args()
   end

   defp run_args do
      if iex_running?(), do: [], else: ["--no-halt"]
   end

   defp iex_running? do
      Code.ensure_loaded?(IEx) and IEx.started?()
   end
end
