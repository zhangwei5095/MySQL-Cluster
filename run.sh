#!/bin/bash

# Parameter values for $1:
# ndb_mgm:  console client (default)
# ndbd:     data node
# ndb_mgmd: manager node
# mysqld:   sql node

# Parameter value for $2 (optionally):
# The ndb_mgmd ip/hostname

MYSQL_CLUSTER_BIN=${MYSQL_CLUSTER_HOME}/bin
MYSQL_MANAGEMENT_SERVER=$2
MYSQL_MANAGEMENT_PORT=1186

INITIAL=""
RELOAD="--reload"
if [ ! -e /.initial ]; then
    echo "First execution detected. Using --initial parameter."
    INITIAL="--initial"
    RELOAD=""
    touch /.initial
else
    echo "Pre-initialized installation detected. Using --reload parameter."
fi

echo "Using management server ${MYSQL_MANAGEMENT_SERVER}"

if [ $1 == "ndbd" ]; then
    echo "Starting ndbd..."
    ${MYSQL_CLUSTER_BIN}/ndbd --nodaemon ${INITIAL} --connect-string="host=${MYSQL_MANAGEMENT_SERVER}:${MYSQL_MANAGEMENT_PORT}"
elif [ $1 == "ndb_mgmd" ]; then
    echo "Starting ndb_mgmd..."
    ${MYSQL_CLUSTER_BIN}/ndb_mgmd --nodaemon ${RELOAD} ${INITIAL} -f ${MYSQL_CLUSTER_CONFIG} # --no-nodeid-checks --ndb-nodeid=1
elif [ $1 == "mysqld" ]; then
    echo "Starting mysqld_safe..."
    ${MYSQL_CLUSTER_BIN}/mysqld_safe --nodaemon --ndbcluster --ledir=${MYSQL_CLUSTER_BIN} --ndb-connectstring=${MYSQL_MANAGEMENT_SERVER} # --skip-grant-tables
else
    echo "Starting ndb_mgm..."
    ${MYSQL_CLUSTER_BIN}/ndb_mgm ${MYSQL_MANAGEMENT_SERVER}
fi
