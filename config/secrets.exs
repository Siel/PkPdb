case File.read("secrets.conf") do
  {:ok, content} ->
    [user, password] =
      content
      |> String.split(",")

    System.put_env("EMAIL_USER", user)
    System.put_env("EMAIL_PASSWORD", password)

  {:error, _reason} ->
    nil
end
