defmodule GlowingTelegramTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest GlowingTelegram

  @opts GlowingTelegram.Endpoint.init([])

  test "GET /" do
    # Create a test connection
    conn = conn(:get, "/")

    # Invoke the plug
    conn = GlowingTelegram.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert Poison.decode!(conn.resp_body) == %{"data" => nil, "messages" => ["Hello from BOT :)"]}
  end

  test "GET /fake" do
    # Create a test connection
    conn = conn(:get, "/fake")

    # Invoke the plug
    conn = GlowingTelegram.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404

    assert Poison.decode!(conn.resp_body) == %{
             "data" => nil,
             "messages" => ["Requested page not found!"]
           }
  end

  test "GET /metrics/fake" do
    # Create a test connection
    conn = conn(:get, "/metrics/fake")

    # Invoke the plug
    conn = GlowingTelegram.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404

    assert Poison.decode!(conn.resp_body) == %{
             "data" => nil,
             "messages" => ["Requested page not found!"]
           }
  end

  test "POST /metrics/dump with valid payload" do
    body = Poison.encode!(%{metrics: ["some", "stuff"]})

    conn =
      conn(:post, "/metrics/dump", body)
      |> put_req_header("content-type", "application/json")

    conn = GlowingTelegram.Endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 202
    assert Poison.decode!(conn.resp_body) == %{"data" => ["some", "stuff"], "messages" => nil}
  end

  test "POST /metrics/dump with invalid payload" do
    body = Poison.encode!(%{bollocks: true})

    conn =
      conn(:post, "/metrics/dump", body)
      |> put_req_header("content-type", "application/json")

    conn = GlowingTelegram.Endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 400

    assert Poison.decode!(conn.resp_body) == %{
             "data" => nil,
             "messages" => ["Not a valid payload %{\"bollocks\" => true}"]
           }
  end
end
