defmodule MidtermProjectWeb.Router do
  use MidtermProjectWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MidtermProjectWeb do
    pipe_through :api
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug, schema: MidtermProjectWeb.Schema

    if Mix.env() === :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: MidtermProjectWeb.Schema,
        socket: MidtermProjectWeb.UserSocket,
        interface: :playground
    end
  end
end
