#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres <<-EOSQL
    CREATE USER grafana WITH ENCRYPTED PASSWORD 'grafana';
    CREATE DATABASE grafana WITH OWNER = grafana;
EOSQL