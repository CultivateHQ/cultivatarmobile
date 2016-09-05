defmodule CbWeb.PageController do
  use CbWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
