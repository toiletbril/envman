#!/bin/bash

# This file will be executed from inside of the container upon it's startup.

set -eux -o pipefail

H="/home/gpadmin"

# Start a permanent lldb platform server.
#
# (lldb) platform select remote linux
# (lldb) platform connect 172.17.0.<...>:7777
(
  while :; do lldb-server-15 p --server --listen '*:7777' --gdbserver-port='7778' > /dev/null 2>&1; done
) & disown %1

export PGDATABASE='postgres'
export PATH="/usr/lib/ccache:$PATH"
export CCACHE_DIR='/public/ccache'

exec bash "$@"
