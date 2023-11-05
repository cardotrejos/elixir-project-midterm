defmodule MidtermProject.Repo do
  use Ecto.Repo,
    otp_app: :midterm_project,
    adapter: Ecto.Adapters.Postgres
end
