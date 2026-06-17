#!/bin/bash

# This file will be placed inside of the container.
set -eu
U=gpadmin
V="${V:-1}"

if [ "$V" = 2 ]; then
  R=/sys/fs/cgroup
  [ -e "$R/cgroup.controllers" ] || { echo "not a cgroup v2 unified hierarchy" >&2; exit 1; }
  D="$R/gpdb"
  [ -e "$D" ] || mkdir "$D"

  for C in cpuset cpu io memory; do
    grep -qw "$C" "$R/cgroup.controllers" || { echo "missing controller: $C" >&2; exit 1; }
    grep -qw "$C" "$R/cgroup.subtree_control" || echo "+$C" > "$R/cgroup.subtree_control"
    grep -qw "$C" "$D/cgroup.subtree_control" || echo "+$C" > "$D/cgroup.subtree_control"
  done

  chown "$U":"$U" "$R/cgroup.procs"

  chown -R "$U":"$U" "$D"
else
  for C in cpu cpuacct cpuset memory; do
    D="/sys/fs/cgroup/$C/gpdb"
    [ -d "/sys/fs/cgroup/$C" ] || { echo "missing controller: $D" >&2; exit 1; }
    [ -e "$D" ] || mkdir "$D"
    chown -R "$U":"$U" "$D"
    find "/sys/fs/cgroup/$C/gpdb" -type d -exec chmod u+x {} +
  done
fi
