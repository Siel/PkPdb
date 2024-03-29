defmodule Core.AccountsFixtures do
  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_name, do: "Julian"
  def valid_user_last_name, do: "Otalvaro"
  def valid_user_password, do: "hello world!"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        password: valid_user_password(),
        name: valid_user_name(),
        last_name: valid_user_last_name()
      })
      |> Core.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end

  def confirm_user(user) do
    token =
      extract_user_token(fn url ->
        Core.Accounts.deliver_user_confirmation_instructions(user, url)
      end)

    # {:ok, token} = Base.url_decode64(token, padding: false)
    Core.Accounts.confirm_user(token)
  end
end
