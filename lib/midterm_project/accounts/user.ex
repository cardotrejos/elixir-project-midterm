defmodule MidtermProject.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias MidtermProject.Accounts.{User, Wallet}

  @required_params [:name, :email]

  schema "users" do
    field :email, :string
    field :name, :string

    has_many :wallets, Wallet

    timestamps()
  end

  def create_changeset(params) do
    changeset(%User{}, params)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint(:email)
  end
end
