defmodule Core.Mailer do
  use Swoosh.Mailer, otp_app: :core
end

defmodule Core.UserEmail do
  import Swoosh.Email

  def send(to, content) do
    new()
    |> to({"User", to})
    |> from({"PkPdb", "test@test.com"})
    |> subject("You have an email!")
    |> text_body(content)
  end
end
