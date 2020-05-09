# Adjust

### Requirements
1. Elixir 1.10.2/Erlang/OTP 22
2. PostgreSQL 10 installed with default postgres database

### Instructions
* Install dependencies with `mix deps.get`
* Start server with `mix adjust.server` and wait for it get started
* Follow instructions on console or given below
* Now you can visit [localhost:4000](http://localhost:4000 "Adjust server") from your browser.
* For source data visit [localhost:4000/dbs/foo/tables/source](http://localhost:4000/dbs/foo/tables/source "to download source.csv")
* For dest data visit [localhost:4000/dbs/bar/tables/dest](http://localhost:4000/dbs/bar/tables/dest "to download dest.csv")
