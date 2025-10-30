#!/bin/bash

# This file will be executed from inside of the container upon it's creation.

set -ex -o pipefail

git config --global --add safe.directory '*'

H='/home/gpadmin'
cd "$H" || exit 1

source './gpdb_src/concourse/scripts/common.bash'
'./gpdb_src/concourse/scripts/setup_gpadmin_user.bash' 'ubuntu22'

install -o gpadmin -g gpadmin -m700 -d /sys/fs/cgroup/{memory,cpu,cpuset}/gpdb
chmod 600 /sys/fs/cgroup/{memory,cpu,cpuset}/gpdb/*
chown gpadmin:gpadmin /sys/fs/cgroup/{memory,cpu,cpuset}/gpdb/*

mkdir -p '/usr/local/greenplum-db-devel'
chown -R gpadmin:gpadmin '/usr/local/greenplum-db-devel'

# ~~whatever retard created docker I hate you~~
# Set up default mirrors.
cat <<EOF > '/etc/apt/sources.list'
deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
deb http://archive.canonical.com/ubuntu/ jammy partner
EOF

apt update
apt install -y tmux gdb gdbserver vim lldb-15 mold ccache

# Set up Ccache, Golang

G='go1.21.3.linux-amd64.tar.gz'
wget -q "https://go.dev/dl/$G"
tar -C '/usr/local' -xzf "$G"
rm "$G"

cat <<EOF >> '/home/gpadmin/.bashrc'
GOPATH='/usr/local/go'
PATH="/usr/lib/ccache:\$GOPATH/bin:\$PATH"
EOF

C="$H/container-scripts"

# Finally setup the auxilliary files!
ln -sf "$C/container-run-configure.sh" "$H/gpdb_src/run-configure"
ln -sf "$C/container-env.sh" "$H/env"
ln -sf "$C/container-setup-cgroup1.sh" "$H/setup-cgroups"
