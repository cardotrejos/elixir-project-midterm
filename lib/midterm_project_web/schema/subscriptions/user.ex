defmodule MidtermProjectWeb.Schema.Subscriptions.User do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    @desc "Broadcasts newly created user"
    field :created_user, :user do
      config fn _map, _resolution ->
        {:ok, topic: "new_user"}
      end

      trigger :create_user, topic: fn _ -> "new_user" end
    end
  end
end
