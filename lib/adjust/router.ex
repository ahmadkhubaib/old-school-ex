defmodule Adjust.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  @content_type "application/json"
  @read_content_type "text/csv"

  get "/" do
    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(200, welcome())
  end

  get "/dbs/foo/tables/source" do
    conn
    |> put_resp_content_type(@read_content_type)
    |> send_chunked(200)
    |> foo_data
  end

  get "/dbs/bar/tables/dest" do
    conn
    |> put_resp_content_type(@read_content_type)
    |> send_chunked(200)
    |> bar_data
  end

  match _ do
    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(404, error())
  end

  defp welcome do
  encode("server", "Please use 'localhost:4000/dbs/foo/tables/source' or 'localhost:4000/dbs/bar/tables/dest' as your endpoint")
  end

  defp foo_data(conn) do
    %Postgrex.Result{columns: columns, rows: rows} = Postgrex.query!(:foo, "SELECT * FROM source;",[])
    rows = [columns | rows]
    for [a,b,c] <- rows do
      case Plug.Conn.chunk(conn, "#{a},#{b},#{c}\n") do
        {:ok, next} ->
          {:cont, next}
        {:error, :closed} ->
          {:halt, conn}
      end
    end
    conn
  end

  defp bar_data(conn) do
    %Postgrex.Result{columns: columns, rows: rows} = Postgrex.query!(:bar, "SELECT * FROM dest",[])
    rows = [columns | rows]
    for [a,b,c] <- rows do
      case Plug.Conn.chunk(conn, "#{a},#{b},#{c}\n") do
        {:ok, next} ->
          {:cont, next}
        {:error, :closed} ->
          {:halt, conn}
      end
    end
    conn
  end

  defp error() do
    encode("error", "Nothing Found of your interest :-( ")
  end

  defp encode(response_type, response_message) do
    Poison.encode!(%{
      response_type: response_type,
      message: response_message
    })
  end
end