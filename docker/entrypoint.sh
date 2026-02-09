#!/usr/bin/env sh
set -e

cd /var/www/html

if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
fi

if [ ! -f database/database.sqlite ]; then
  touch database/database.sqlite
fi

is_valid_key() {
  php -r '
    $key = getenv("APP_KEY") ?: "";
    if (str_starts_with($key, "base64:")) {
        $key = base64_decode(substr($key, 7), true);
    }
    $len = is_string($key) ? strlen($key) : 0;
    exit(in_array($len, [16, 32], true) ? 0 : 1);
  '
}

if [ -n "${APP_KEY:-}" ] && ! is_valid_key; then
  echo "Invalid APP_KEY provided, regenerating." >&2
  unset APP_KEY
fi

if [ -z "${APP_KEY:-}" ]; then
  php artisan key:generate --force
fi

exec "$@"
