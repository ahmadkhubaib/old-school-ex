use Mix.Config

# DB variables, NEEDs to be changed
db = [
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  database: "postgres",
  name: :db
]

# Cowboy Config
config :adjust, Adjust.Endpoint, port: 4000

# DB config
config :adjust, Adjust.DB, db
# DB config for database foo
config :adjust, FOO, Keyword.merge(db, [database: "foo", name: :foo])
# DB config for database bar
config :adjust, BAR, Keyword.merge(db, [database: "bar", name: :bar])