#!/bin/bash

# This file will be placed inside of the container.

U="$USER"

sudo bash <<EOF
install -o "$U" -g "$U" -m700 -d /sys/fs/cgroup/{memory,cpu,cpuset,cpuacct}/gpdb
chmod 600 /sys/fs/cgroup/{memory,cpu,cpuset,cpuacct}/gpdb/*
chown "$U":"$U" /sys/fs/cgroup/{memory,cpu,cpuset,cpuacct}/gpdb/*
EOF
