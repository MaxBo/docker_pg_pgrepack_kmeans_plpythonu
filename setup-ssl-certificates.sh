#!/usr/bin/env bash

source /env-data.sh

# This script will setup default SSL config

# /etc/ssl/private can't be accessed from within container for some reason
# (@andrewgodwin says it's something AUFS related)  - taken from https://github.com/orchardup/docker-postgresql/blob/master/Dockerfile

mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

# Needed under debian, wasnt needed under ubuntu
mkdir -p ${PGSTAT_TMP}
chmod 0777 ${PGSTAT_TMP}