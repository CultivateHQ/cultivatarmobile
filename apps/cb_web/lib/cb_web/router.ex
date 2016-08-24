defmodule CbWeb.Router do
  @moduledoc """
  A Plug router that acts as an interface to control the robot. The
  control page is displayed initially with `get /`. All state changing operations
  are posts.
  """

  use Plug.Router
  plug Plug.Parsers, parsers: [:urlencoded]
  alias CbLocomotion.Locomotion
  alias CbWeb.Html

  plug :match
  plug :dispatch

  def start_link do
    cowboy_options = Application.get_env(:cb_web, :cowboy_options)
    {:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [], cowboy_options
  end

  get "/" do
    send_resp(conn, 200, "Hello" |> Html.control_page)
  end

  get "/cultivatormobile.css" do
    send_resp(conn, 200, Html.css)
  end

  post "forward" do
    Locomotion.forward
    send_resp(conn, 200, "Forward!" |> Html.control_page)
  end

  post "back" do
    Locomotion.reverse
    send_resp(conn, 200, "Back!" |> Html.control_page)
  end

  post "stop" do
    Locomotion.stop
    send_resp(conn, 200, "Stopped!" |> Html.control_page)
  end

  post "step_rate" do
    step_rate = conn.params["step_rate"] |> String.to_integer
    Locomotion.set_step_rate(step_rate)

    send_resp(conn, 200, "Stepping at #{step_rate}" |> Html.control_page)
  end

  post "turn_left" do
    Locomotion.turn_left
    send_resp(conn, 200, "Left!" |> Html.control_page)
  end

  post "turn_right" do
    Locomotion.turn_right
    send_resp(conn, 200, "Right!" |> Html.control_page)
  end

  match _ do
    send_resp(conn, 404, "<p>Not found.</p><hr/><p>#{conn |> inspect}</p>")
  end

end
