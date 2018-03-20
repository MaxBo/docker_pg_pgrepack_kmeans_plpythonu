#!/bin/sh
set -e

# Perform all actions as user 'postgres'
export PGUSER=postgres

# Add pgRouting Functions to the database
psql --dbname="$POSTGRES_DB" <<EOSQL
CREATE LANGUAGE plpythonu;
CREATE EXTENSION pg_repack;
CREATE EXTENSION kmeans;
EOSQL