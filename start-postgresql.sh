#!/usr/bin/env bash

# This script will run as the postgres user due to the Dockerfile USER directive
set -e

# Setup postgres CONF file
source /env-data.sh

# Setup ssl
source /setup-ssl-certificates.sh

# Optimize kernel
source /optimize-kernel.sh

if [ -z "$REPLICATE_FROM" ]; then
	# This means this is a master instance. We check that database exists
	echo "Setup master database"
	source /setup-database.sh
else
	# This means this is a slave/replication instance.
	echo "Setup slave database"
	source /setup-replication.sh
fi

# If no arguments passed to entrypoint, then run postgres by default
if [ $# -eq 0 ];
then
	echo "Start Postgres in foreground"
	su - postgres -c "$SETVARS $POSTGRES -D $DATADIR -c config_file=$CONF"
fi

# If arguments passed, run postgres with these arguments
# This will make sure entrypoint will always be executed
if [ "${1:0:1}" = '-' ]; then
	# append postgres into the arguments
	set -- postgres "$@"
fi

exec su - "$@"