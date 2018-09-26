defmodule GlowingTelegram.Router do
  use Plug.Router

  require Logger

  plug(:match)
  plug(:dispatch)

  post "/dump" do
    {status, data, messages} =
      case conn.body_params do
        %{"metrics" => metrics} -> {:accepted, metrics, nil}
        _ -> {:bad_request, nil, ["Not a valid payload #{inspect(conn.body_params)}"]}
      end

    if data do
      Logger.debug("Metrics values: #{inspect(data)}")
    else
      Logger.error("Bad Request: not a valid payload #{inspect(conn.body_params)}")
    end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, msg_out(data, messages))
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:not_found, msg_out(nil, ["Requested page not found!"]))
  end

  defp msg_out(data, messages) do
    Poison.encode!(%{data: data, messages: messages})
  end
end
