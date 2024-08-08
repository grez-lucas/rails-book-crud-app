#!/usr/bin/env bash
set -xeuo pipefail

# Wait for the database and Redis to be ready
./script/wait-for-tcp.sh db 5432

# Remove the PID file if it exists
if [[ -f ./tmp/pids/server.pid ]]; then
  rm ./tmp/pids/server.pid
fi

# Install dependencies
bundle

# Setup the database
if ! [[ -f .db-created ]]; then
  bin/rails db:drop db:create
  touch .db-created
fi

# Migrate and seed the database
bin/rails db:migrate
bin/rails db:fixtures:load

if ! [[ -f .db-seeded ]]; then
  bin/rails db:seed
  touch .db-seeded
fi

bin/rails server --port 3000 --binding 0.0.0.0
