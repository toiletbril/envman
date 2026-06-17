#!/bin/bash

# This file will be placed inside of the container.
set -eu
U=gpadmin
for c in cpu cpuacct cpuset memory; do
  d="/sys/fs/cgroup/$c/gpdb"
  [ -d "/sys/fs/cgroup/$c" ] || { echo "missing controller: $c" >&2; exit 1; }
  [ -e "$d" ] || mkdir "$d"
  chown -R "$U":"$U" "$d"
  find "/sys/fs/cgroup/$c/gpdb" -type d -exec chmod u+x {} +
done
