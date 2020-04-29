[user, password] =
  File.read!("secrets.conf")
  |> String.split(",")


System.put_env("EMAIL_USER", user)
System.put_env("EMAIL_PASSWORD", password)
