#!/bin/bash

set -ue

if test $# -lt 1; then
  echo "$0 <content id/admin> [p/m]"
  echo 'view gpdb segment directory corresponding to segment id.'
  echo '"admin" opens gpAdminLogs/.'
  exit 1
fi

CID="$1"
if test "$CID" = 'admin'; then
  vim '/home/gpadmin/gpAdminLogs'
  exit 0
fi

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

vim "$MASTER_DATA_DIRECTORY/../../$DIR/"
