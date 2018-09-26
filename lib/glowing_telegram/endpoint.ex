defmodule GlowingTelegram.Endpoint do
  use Plug.Router

  require Logger

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/metrics/", to: GlowingTelegram.Router)

  get "/" do
    Logger.info("Hit path </>, thanks for using me.")

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, msg_out(nil, ["Hello from BOT :)"]))
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:not_found, msg_out(nil, ["Requested page not found!"]))
  end

  defp msg_out(data, messages) do
    Poison.encode!(%{data: data, messages: messages})
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    Plug.Adapters.Cowboy2.http(__MODULE__, [])
  end
end
