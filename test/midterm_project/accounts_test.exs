defmodule MidtermProject.AccountsTest do
  use MidtermProject.DataCase

  alias MidtermProject.{
    Accounts,
    Accounts.User,
    Accounts.Wallet,
    Swap
  }

  import MidtermProject.AccountsFixtures,
    only: [user: 1, wallet: 1, wallet2: 1, user2: 1, user2_wallet: 1]

  @currencies {:USD, :CAD}

  @valid_user_params %{name: "Harry", email: "dresden@example.com"}
  @valid_wallet_params %{currency: :CAD, cent_amount: 1_000}
  @invalid_user_params %{email: nil, name: nil}
  @invalid_wallet_params %{user_id: nil, currency: nil, cent_amount: nil}

  describe "all_users/1" do
    setup :user

    test "should retrieve all users when no specific criteria are provided", %{
      user: %{id: id, name: name, email: email}
    } do
      assert [%User{id: ^id, name: ^name, email: ^email}] = Accounts.all_users(%{})
    end

    test "should retrieve user when specific criteria are provided", %{
      user: %{id: id, name: name, email: email}
    } do
      assert [%User{id: ^id, name: ^name, email: ^email}] = Accounts.all_users(%{name: name})
    end

    test "should return an empty collection when no users match the criteria" do
      assert [] = Accounts.all_users(%{name: "does not exist"})
    end
  end

  describe "find_user/1" do
    setup :user

    test "should return the user details when the user is found", %{
      user: %{id: id, name: name, email: email}
    } do
      assert {:ok, %User{id: ^id, name: ^name, email: ^email}} = Accounts.find_user(%{id: id})
    end

    test "should provide the found user when multiple search parameters are specified",
         %{
           user: %{id: id, name: name, email: email}
         } do
      assert {:ok, %User{id: ^id, name: ^name, email: ^email}} =
               Accounts.find_user(%{id: id, name: name})
    end

    test "should indicate a not_found error when no parameters are specified" do
      assert {:error,
              %ErrorMessage{
                code: :not_found,
                message: "no records found",
                details: %{params: %{}, query: MidtermProject.Accounts.User}
              }} ===
               Accounts.find_user(%{})
    end

    test "should signal an error with detailed info when the user cannot be located", %{
      user: %{id: id}
    } do
      assert Accounts.find_user(%{id: id + 1}) ===
               {:error,
                %ErrorMessage{
                  code: :not_found,
                  details: %{params: %{id: id + 1}, query: MidtermProject.Accounts.User},
                  message: "no records found"
                }}
    end
  end

  describe "create_user/1" do
    test "should successfully create a new user with valid parameters" do
      assert {:ok, %User{email: "dresden@example.com", name: "Harry"}} =
               Accounts.create_user(@valid_user_params)

      assert [%User{}] = Repo.all(User)
    end

    test "should prevent creation of a user with a duplicate email address" do
      assert {:ok, %User{email: "dresden@example.com", name: "Harry"}} =
               Accounts.create_user(@valid_user_params)

      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(@valid_user_params)
      assert %{email: ["has already been taken"]} === errors_on(changeset)
    end

    test "should return a validation error when user parameters are invalid" do
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(@invalid_user_params)
      assert %{email: ["can't be blank"], name: ["can't be blank"]} === errors_on(changeset)
    end
  end

  describe "update_user/2" do
    setup :user

    test "should update the user information with the provided parameters", %{user: user} do
      assert [%User{email: "email@example.com"}] = Accounts.all_users(%{})

      assert {:ok, %User{email: "wizard@example.com"}} =
               Accounts.update_user(user.id, %{email: "wizard@example.com"})

      assert [%User{email: "wizard@example.com"}] = Accounts.all_users(%{})
    end

    test "should return the user unchanged if no update parameters are given",
         %{user: user} do
      assert {:ok, %User{email: "email@example.com"}} = Accounts.update_user(user.id, %{})
      assert [%User{email: "email@example.com"}] = Accounts.all_users(%{})
    end

    test "should return an error when attempting to update a user with another user's email",
         %{user: user} do
      assert [%User{email: "email@example.com"}] = Accounts.all_users(%{})

      assert {:ok, %User{email: user2_email}} =
               Accounts.create_user(%{name: "user2", email: "user2@example.com"})

      assert {:error, %Ecto.Changeset{} = changeset} =
               Accounts.update_user(user.id, %{email: user2_email})

      assert %{email: ["has already been taken"]} === errors_on(changeset)
    end
  end

  describe "delete_user/1" do
    setup [:user, :wallet]

    test "should remove a user and their associated wallets", %{user: user} do
      id = user.id
      assert [%Wallet{user_id: ^id}] = Accounts.all_wallets()
      Accounts.delete_user(user)

      assert Accounts.find_user(%{id: user.id}) ===
               {:error,
                %ErrorMessage{
                  code: :not_found,
                  details: %{params: %{id: id}, query: MidtermProject.Accounts.User},
                  message: "no records found"
                }}

      assert Accounts.all_users() === []
      assert Accounts.all_wallets() === []
    end
  end

  describe "all_wallets/1" do
    setup [:user, :wallet]

    test "should fetch all wallets when no specific criteria are given", %{
      user: %{id: id},
      wallet: %{currency: currency, cent_amount: cent_amount}
    } do
      assert [%Wallet{user_id: ^id, currency: ^currency, cent_amount: ^cent_amount}] =
               Accounts.all_wallets()
    end

    test "should list all wallets that match the given criteria", %{
      user: %{id: id}
    } do
      assert [%Wallet{user_id: ^id, currency: :CAD, cent_amount: 1_000}] =
               Accounts.all_wallets(%{currency: :CAD})
    end
  end

  describe "find_wallet/1" do
    setup [:user, :wallet]

    test "should return the wallet details when the specified wallet exists",
         %{
           user: %{id: id},
           wallet: %{currency: currency}
         } do
      assert {:ok, %Wallet{user_id: ^id}} =
               Accounts.find_wallet(%{user_id: id, currency: currency})
    end

    test "should indicate an error with details when the wallet cannot be found",
         %{user: %{id: id}, wallet: %{currency: currency}} do
      assert Accounts.find_wallet(%{id: id + 1, currency: currency}) ===
               {:error,
                %ErrorMessage{
                  code: :not_found,
                  details: %{
                    params: %{id: id + 1, currency: :CAD},
                    query: MidtermProject.Accounts.Wallet
                  },
                  message: "no records found"
                }}
    end
  end

  describe "create_wallet/1" do
    setup :user

    test "should successfully create a new wallet with valid parameters", %{user: %{id: id}} do
      create_params = Map.put(@valid_wallet_params, :user_id, id)

      assert {:ok, %Wallet{user_id: ^id, currency: :CAD, cent_amount: 1_000}} =
               Accounts.create_wallet(create_params)

      assert [%Wallet{user_id: ^id}] = Repo.all(Wallet)
    end

    test "should not allow the same user to have multiple wallets in the same currency", %{user: %{id: id}} do
      create_params = Map.put(@valid_wallet_params, :user_id, id)

      assert {:ok, %Wallet{user_id: ^id, currency: :CAD, cent_amount: 1_000}} =
               Accounts.create_wallet(create_params)

      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_wallet(create_params)
      assert %{currency: ["has already been taken"]} === errors_on(changeset)
    end

    test "should permit the creation of multiple wallets in different currencies for one user", %{user: %{id: id}} do
      create_params = Map.put(@valid_wallet_params, :user_id, id)

      assert {:ok, %Wallet{user_id: ^id, currency: :CAD, cent_amount: 1_000}} =
               Accounts.create_wallet(create_params)

      new_currency_params = Map.put(create_params, :currency, :USD)

      assert {:ok, %Wallet{user_id: ^id, currency: :USD, cent_amount: 1_000}} =
               Accounts.create_wallet(new_currency_params)

      assert [%Wallet{user_id: ^id}, %Wallet{user_id: ^id}] = Repo.all(Wallet)
    end

    test "should return an error when wallet creation parameters are invalid" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Accounts.create_wallet(@invalid_wallet_params)

      assert %{
               user_id: ["can't be blank"],
               currency: ["can't be blank"],
               cent_amount: ["can't be blank"]
             } === errors_on(changeset)
    end
  end

  describe "update_wallet/2" do
    setup [:user, :wallet]

    test "should update the wallet when valid update parameters are provided", %{user: %{id: id}, wallet: %{currency: currency}} do
      assert {:ok,
              %Wallet{
                user_id: ^id,
                currency: ^currency,
                cent_amount: 5_000
              }} =
               Accounts.update_wallet(%Wallet{user_id: id, currency: currency}, %{
                 cent_amount: 5_000
               })

      assert [%Wallet{cent_amount: 5_000}] = Accounts.all_wallets()
    end

    test "does not alter wallet when update parameters are absent",
         %{user: %{id: id}, wallet: %Wallet{currency: currency, cent_amount: cent_amount}} do
      assert {:ok,
              %Wallet{
                user_id: ^id,
                currency: ^currency,
                cent_amount: ^cent_amount
              }} = Accounts.update_wallet(%Wallet{user_id: id, currency: currency}, %{})

      assert [%Wallet{cent_amount: 1_000}] = Accounts.all_wallets()
    end
  end

  describe "update_balance/2" do
    setup [:user, :wallet]

    test "updates the wallet balance accordingly", %{user: %{id: id}, wallet: %{currency: currency}} do
      assert {:ok,
              %Wallet{
                user_id: ^id,
                currency: ^currency,
                cent_amount: 0
              }} =
               Accounts.update_balance(%Wallet{user_id: id, currency: currency}, %{
                 cent_amount: -1_000
               })

      assert [%Wallet{cent_amount: 0}] = Accounts.all_wallets()
    end
  end

  describe "delete_wallet/1" do
    setup [:user, :wallet]

    test "removes the wallet from records", %{user: %{id: id}, wallet: %{currency: currency} = wallet} do
      Accounts.delete_wallet(wallet)

      assert Accounts.find_wallet(%{user_id: id, currency: currency}) ===
               {:error,
                %ErrorMessage{
                  code: :not_found,
                  details: %{
                    params: %{user_id: id, currency: currency},
                    query: MidtermProject.Accounts.Wallet
                  },
                  message: "no records found"
                }}

      assert Accounts.all_wallets() === []
    end
  end

  describe "send_amount/1" do
    setup [:user, :wallet, :wallet2, :user2, :user2_wallet]

    test "transfers funds between user wallets", %{
      user: user,
      wallet: %{
        id: from_wallet_id,
        cent_amount: from_wallet_cent_amount,
        currency: from_wallet_currency
      },
      user2: user2,
      user2_wallet: %{
        id: to_wallet_id,
        cent_amount: to_wallet_cent_amount,
        currency: to_wallet_currency
      }
    } do
      assert {:ok,
              %{
                cent_amount: 100,
                exchange_rate: 1.0,
                from_currency: :CAD,
                to_currency: :CAD,
                update_from_wallet: %Wallet{
                  cent_amount: 900,
                  currency: :CAD,
                  id: ^from_wallet_id
                },
                update_to_wallet: %Wallet{
                  cent_amount: 1100,
                  currency: :CAD,
                  id: ^to_wallet_id
                }
              }} =
               Accounts.send_amount(%{
                 from_user_id: user.id,
                 from_currency: from_wallet_currency,
                 cent_amount: 100,
                 to_user_id: user2.id,
                 to_currency: to_wallet_currency
               })

      from_wallet_cent_amount = from_wallet_cent_amount - 100
      to_wallet_cent_amount = to_wallet_cent_amount + 100

      assert {:ok,
              %Wallet{currency: ^from_wallet_currency, cent_amount: ^from_wallet_cent_amount}} =
               Accounts.find_wallet(%{id: from_wallet_id})

      assert {:ok, %Wallet{currency: ^to_wallet_currency, cent_amount: ^to_wallet_cent_amount}} =
               Accounts.find_wallet(%{id: to_wallet_id})
    end

    test "fails to send money if wallets are not found", %{
      user: user,
      wallet: %{
        currency: from_wallet_currency
      },
      user2: user2,
      user2_wallet: %{
        currency: to_wallet_currency
      }
    } do
      assert {:error, :check_wallets_found, %ErrorMessage{code: :not_found}, _} =
               Accounts.send_amount(%{
                 from_user_id: user.id,
                 from_currency: from_wallet_currency,
                 cent_amount: 100,
                 to_user_id: user2.id + 1,
                 to_currency: to_wallet_currency
               })
    end

    test "fails to send money if exchange rate is missing", %{
      user: user,
      wallet: %{currency: from_wallet_currency},
      wallet2: %{currency: to_wallet_currency}
    } do
      assert {:error, :exchange_rate, %ErrorMessage{code: :not_found}, _} =
               Accounts.send_amount(%{
                 from_user_id: user.id,
                 from_currency: from_wallet_currency,
                 cent_amount: 100,
                 to_user_id: user.id,
                 to_currency: to_wallet_currency
               })
    end
  end

  describe "get_total_worth/1" do
    setup [:user, :wallet, :wallet2, :user2, :test_cache]

    test "calculates the total worth in a specified currency", %{
      user: %{id: id},
      wallet: %{currency: currency}
    } do
      assert {:ok, 2110, ^currency} = Accounts.get_total_worth(%{user_id: id, currency: currency})
    end

    test "reports an error if exchange rate is unavailable", %{
      user: %{id: id},
      wallet: %{currency: wallet1_currency},
      wallet2: %{currency: currency}
    } do
      assert {:error,
              %ErrorMessage{
                code: :not_found,
                details: %{
                  from_currency: ^wallet1_currency,
                  to_currency: ^currency
                },
                message: "Exchange rate currently not available. Please try again!"
              }} = Accounts.get_total_worth(%{user_id: id, currency: currency})
    end

    test "reports an error if user has no wallets", %{
      user2: %{id: id}
    } do
      assert {:error,
              %ErrorMessage{
                code: :not_found,
                details: %{user_id: ^id},
                message: "No wallets found for this User Id."
              }} = Accounts.get_total_worth(%{user_id: id, currency: :CAD})
    end
  end

  defp test_cache(_) do
    start_supervised!({ConCache, name: :test_cache, ttl_check_interval: 20, global_ttl: 3_000})
    Swap.start_link(@currencies, :test_cache)
    :ok
  end
end
