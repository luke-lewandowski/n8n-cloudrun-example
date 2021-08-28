#!/bin/sh

# Connection String
# Setup GCP SQL Proxy
MYSQL_CONN_NAME="${GOOGLE_PROJECT}:${REGION}:${DB_INSTANCE}"

echo "Starting SQL proxy..."
/cloud_sql_proxy -instances=${MYSQL_CONN_NAME}=tcp:5432 &

echo "Waiting for proxy to start..."
sleep 20

echo "Starting n8n"
if [ -d /root/.n8n ] ; then
  chmod o+rx /root
  chown -R node /root/.n8n
  ln -s /root/.n8n /home/node/
fi

chown -R node /home/node

if [ "$#" -gt 0 ]; then
  # Got started with arguments
  exec su-exec node "$@"
else
  # Got started without arguments
  exec su-exec node n8n
fi