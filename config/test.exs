use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pxblog, PxblogWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :pxblog, Pxblog.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "pxblog_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Config ComeOnIn
config :comeonin, bcrypt_log_rounds: 4

# Config mailer
config :pxblog, Pxblog.Mailer,
  adapter: Swoosh.Adapters.Test
