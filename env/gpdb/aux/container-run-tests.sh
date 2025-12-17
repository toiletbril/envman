#!/bin/bash

set -ue

if test $# -lt 2; then
  echo "$0 <isolation2/resgroup/regress/prc> <test1> [test2, ..]"
  exit 1
fi

SUITE="$1"
shift

validate_dir()
{
  DIR="$1"
  if test "$PWD" != "$1"; then
    pushd "$1" || exit 1
  fi
}

case "$SUITE" in
  'isolation2')
    DIR='/home/gpadmin/gpdb_src/src/test/isolation2'
    RUNNER='pg_isolation2_regress'
    INIT_FILE='./init_file_isolation2'
    DB_NAME='isolation2resgrouptest'
  ;;
  'resgroup')
    DIR='/home/gpadmin/gpdb_src/src/test/isolation2'
    RUNNER='pg_isolation2_regress'
    INIT_FILE='./init_file_resgroup'
    DB_NAME='isolation2test'
  ;;
  'regress')
    DIR='/home/gpadmin/gpdb_src/src/test/regress'
    RUNNER='pg_regress'
    INIT_FILE='./init_file'
    DB_NAME='regress'
  ;;
  'prc')
    DIR='/home/gpadmin/gpdb_src/src/test/isolation2'
    RUNNER='pg_isolation2_regress'
    INIT_FILE='./init_file_isolation2'
    DB_NAME='isolation2parallelretrcursor'
    ;;
  *)
  echo "$0 <isolation2/resgroup/regress/prc> <test1> [test2, ..]"
  exit 1
  ;;
esac

validate_dir "$DIR"

if ! test -f "./$RUNNER"; then
  make install
fi

"./$RUNNER" --init-file=/home/gpadmin/gpdb_src/src/test/regress/init_file \
            --load-extension=gp_inject_fault --init-file="$INIT_FILE" \
            --dbname="$DB_NAME" "$@"

popd || exit 1
