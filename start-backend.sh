#!/bin/sh
# Backend launcher: loads .env vars then forces PORT=3000
# to avoid clash with nginx (which listens on Railway's PORT=5000).
cd /app/apps/backend

# Load all vars from root .env (DATABASE_URL, REDIS_URL, JWT_SECRET, etc.)
set -a
[ -f /app/.env ] && . /app/.env
set +a

# Override: backend always on 3000, nginx on 5000
export PORT=3000
export TZ=UTC

exec node --experimental-require-module ./dist/apps/backend/src/main.js
