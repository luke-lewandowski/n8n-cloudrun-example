#!/bin/zsh

PORT_NUM="tcp:5432"
CONN_STR="project-name:us-central1:postgres"

./cloud_sql_proxy -instances="${CONN_STR}=${PORT_NUM}"