#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

exec "$@"

if [ "${*}" == "./bin/rails server" ]; then 
  ./bin/rails db:create
  ./bin/rails db:prepare
fi

exec "${@}"

exec "corepack prepare yarn@stable --activate && yarn set version 3.2.1 && yarn init"
