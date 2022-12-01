#!/usr/bin/env bash
# exit on error
#mix local.hex --force
#mix local.rebar --force
mix archive.install hex phx_new 1.6.11 --force
set -o errexit
export SECRET_KEY_BASE="$(mix phx.gen.secret)"
# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
#/home/ubuntu/.nvm/versions/node/v14.15.1/bin/npm install --prefix ./assets
#/home/ubuntu/.nvm/versions/node/v14.15.1/bin/npm run deploy --prefix ./assets
mix phx.digest

# Build the release and overwrite the existing release directory
MIX_ENV=prod mix release --overwrite
mix release --overwrite


PORT=4005 MIX_ENV=prod mix phx.server
