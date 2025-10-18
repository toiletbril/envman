#!/bin/bash

# This file will placed inside of the container.

H="/home/gpadmin"

GP_PATH='/usr/local/greenplum-db-devel/greenplum_path.sh'
GG_PATH='/usr/local/greenplum-db-devel/greengage_path.sh'

test -f "$GP_PATH" && . "$GP_PATH"
test -f "$GG_PATH" && . "$GG_PATH"

E="$H/gpdb_src/gpAux/gpdemo/gpdemo-env.sh"
if test -f $E; then
  . "$E"
  export PS1="(gpdemo.sh env) $PS1"
else
  echo "WARNING: no gpdemo env." >&2
  export PS1="(no gpdemo.sh env) $PS1"
fi

export PGDATABASE='postgres'
