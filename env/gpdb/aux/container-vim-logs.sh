#!/bin/bash

set -ue

if test $# -lt 1; then
  echo "$0 <content id> [p/m]"
  exit 1
fi

CID="$1"
M="${2:-'p'}"

case "$M" in
  'm');;
  'p');;
  *)M='p';;
esac

if test "$CID" = '-1'; then
  if test "$M" = 'm'; then
    DIR='standby'
  else
    DIR='qddir/demoDataDir-1'
  fi
elif test "$M" = 'm'; then
  DIR="dbfast_mirror$CID/demoDataDir$((CID-1))"
else
  DIR="dbfast$CID/demoDataDir$((CID-1))"
fi

vim "$MASTER_DATA_DIRECTORY/../../$DIR/pg_log"
