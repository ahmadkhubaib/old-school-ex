defmodule Adjust.DB do

    def child_spec(opts) do
      %{
        id: __MODULE__,
        start: {__MODULE__, :start_link, [opts]}
      }
    end

    def start_link(_opts) do
      with {:ok, vars} <- config(),
           {:ok, pid} <- Postgrex.start_link(vars),
           {:ok, first_run} <- first_run?(pid),
           {:ok, init_db} <- initialise_db(first_run),
           {:ok, init_tables} <- initialise_tables(init_db),
           {:ok, _copy} <- copy_data(init_tables) do
        {:ok, pid}
      else
        _ ->
          IO.inspect("Ran into some error")
          {:error, :nil}
      end
    end

    defp first_run?(pid) do
      IO.inspect("Checking for Databases 'foo' and 'bar'")
      {:ok,
        %Postgrex.Result{num_rows: num_rows}
      } = Postgrex.query(pid,"
          (SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower('foo'))
          UNION ALL
          (SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower('bar'))
      ", [])
      {:ok, [pid,num_rows]}
    end

    defp initialise_db([pid,0]) do
      IO.inspect("Creating Databases 'foo' and 'bar' ")
      Postgrex.query!(pid, "CREATE DATABASE foo", [])
      Postgrex.query!(pid, "CREATE DATABASE bar", [])
      {:ok, [pid, :created]}
    end

    defp initialise_db([pid,num_rows]) when num_rows > 0 do
      IO.inspect("Databases were already created.")
      {:ok, [pid, :already_init]}
    end

    defp initialise_tables([_pid, :created]) do
      IO.inspect("Creating 1 Million records in 'foo' and 'bar' tables")
      with {:ok, foo_vars} <- foo_config(),
           {:ok, foo } <- Postgrex.start_link(foo_vars),
           {:ok, bar_vars} <- bar_config(),
           {:ok, bar} <- Postgrex.start_link(bar_vars) do
        Postgrex.query!(foo, "
         CREATE UNLOGGED TABLE IF NOT EXISTS source WITH (autovacuum_enabled=false)
          AS
         SELECT a, mod(a, 3) as b, mod(a, 5) as c FROM generate_series(1,1000000) gs(a);
      ", [])
        Postgrex.query!(bar, "
         CREATE UNLOGGED TABLE IF NOT EXISTS dest (a int, b int, c int) WITH (autovacuum_enabled=false);
      ", [])
        {:ok, [foo,bar, :done]}
      end
    end

    defp initialise_tables([_pid, :already_init]) do
      IO.inspect("If you want to continue with current database make sure it have 'source' and 'dest' tables with at least 3 columns.")
      with {:ok, vars} <- foo_config(),
           {:ok, foo} <- Postgrex.start_link(vars),
           {:ok, bar_vars} <- bar_config(),
           {:ok, bar} <- Postgrex.start_link(bar_vars) do
        {:ok, [foo, bar, :exists]}
      end
    end

    defp copy_data([foo,bar, :done]) do
      IO.inspect("Copying records to table 'bar'")
        Postgrex.query!(foo,"COPY source TO '/tmp/test.csv' DELIMITER ',' CSV HEADER;", [])
        Postgrex.query!(bar,"COPY dest FROM '/tmp/test.csv' DELIMITER ',' CSV HEADER;", [])
        IO.inspect("Records copied from 'foo' to 'bar'")
        IO.inspect("Please use 'localhost:4000/dbs/foo/tables/source' or 'localhost:4000/dbs/bar/tables/dest' as your endpoint")
        {:ok, [foo, :copied]}
    end

    defp copy_data([foo, bar, :exists]) do
      IO.inspect("Skipped generating records in tables 'foo' and 'bar .")
      IO.inspect("have a look on console for details.")
      {:ok, [foo, bar, :not_copied]}
    end

    defp config, do: Application.fetch_env(:adjust, __MODULE__)
    defp foo_config, do: Application.fetch_env(:adjust, FOO)
    defp bar_config, do: Application.fetch_env(:adjust, BAR)
end