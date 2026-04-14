#!/bin/sh
set -e

if [ -n "$CONFIG_JSON" ]; then
  printf '%s' "$CONFIG_JSON" > config.json
  echo "config.json written from CONFIG_JSON env var"
fi

if [ -n "$IC_PEM_CONTENTS" ]; then
  printf '%s\n' "$IC_PEM_CONTENTS" | sed 's/\\n/\n/g' > .ic.pem
  chmod 600 .ic.pem
  echo ".ic.pem written from IC_PEM_CONTENTS env var"
fi

exec "$@"
