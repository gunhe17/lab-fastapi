#!/bin/sh

if [ -z "$APP_ENV" ]; then
  echo "Error: APP_ENV is not set."
  exit 1
fi


ENV_FILE=".env/.env.${APP_ENV}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: Environment file not found: $ENV_FILE"
  exit 1
fi


BASE_FILE=".env/.env.base"

if [ ! -f "$BASE_FILE" ]; then
  echo "Error: Environment file not found: $BASE_FILE"
  exit 1
fi


mkdir -p .tmp


process_env_file() {
  local file=$1
  while IFS='=' read -r key value || [ -n "$key" ]; do
    [ -z "$key" ] && continue
    case "$key" in \#*) continue ;; esac

    key=$(printf '%s' "$key" | xargs)
    value=$(printf '%s' "$value" | xargs | sed 's/^["'\'']\(.*\)["'\'']$/\1/')

    printf '%s' "$value" > ".tmp/$key.txt"
  done < "$file"
}
process_env_file "$ENV_FILE"
process_env_file "$BASE_FILE"


generate_compose_secrets() {
  local output=".tmp/docker-compose.secrets.yml"
  echo "secrets:" > "$output"
  for file in .tmp/*.txt; do
    [ -f "$file" ] || continue
    local key=$(basename "$file" .txt | tr '[:upper:]' '[:lower:]')
    printf "  %s:\n    file: ../.tmp/%s.txt\n" "$key" "$(basename "$file" .txt)" >> "$output"
  done
}
generate_compose_secrets