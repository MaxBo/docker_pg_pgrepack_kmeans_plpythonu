#!/usr/bin/env bash

# This script will run as the postgres user due to the Dockerfile USER directive
set -e

# Setup postgres CONF file
source /env-data.sh



# If no arguments passed to entrypoint, then run postgres by default
if [ $# -eq 0 ];
then
	echo "Postgres initialisation process completed .... restarting in foreground"
	su - postgres -c "$SETVARS $POSTGRES -D $DATADIR -c config_file=$CONF"
fi

# If arguments passed, run postgres with these arguments
# This will make sure entrypoint will always be executed
if [ "${1:0:1}" = '-' ]; then
	# append postgres into the arguments
	set -- postgres "$@"
fi

exec su - "$@"