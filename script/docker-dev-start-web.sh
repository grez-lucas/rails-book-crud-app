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
bin/rails db:drop db:create

# Migrate and seed the database
bin/rails db:migrate
bin/rails db:fixtures:load

bin/rails db:seed

bin/rails assets:precompile

bin/rails server --port 3000 --binding 0.0.0.0
