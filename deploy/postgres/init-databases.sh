#!/usr/bin/env bash
# Creates one role and one database per service. Runs once, on first start of
# an empty data volume (docker-entrypoint-initdb.d).
set -euo pipefail

create_db() {
  local db="$1" user="$2" password="$3"
  echo "Creating database '${db}' owned by '${user}'"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres \
    -v db="$db" -v user="$user" -v password="$password" <<'SQL'
CREATE ROLE :"user" WITH LOGIN PASSWORD :'password';
CREATE DATABASE :"db" OWNER :"user";
REVOKE ALL ON DATABASE :"db" FROM PUBLIC;
SQL
}

create_db ledger  "$LEDGER_DB_USER"  "$LEDGER_DB_PASSWORD"
create_db gateway "$GATEWAY_DB_USER" "$GATEWAY_DB_PASSWORD"
