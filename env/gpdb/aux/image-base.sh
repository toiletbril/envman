#!/bin/bash

# Generic driver for Greenplum environment.

# These variables need to be set:
# IMAGE_NAME
# CONTAINER_NAME
# PORT_PREFIX - prefix of postmaster's port. for gpdb 6 -- 6, for gpdb 7 -- 7.
# PORT_VARIATION - random number for a prefix where ports from the container will be mapped to.
# SRC_DIR - directory that contains components you'd like to move inside the container.
# GPDB_SUBDIR - directory under SRC_DIR that contains GPDB source code.

# Specify image name as BEAST_MODE if you want to recreate the container based
# on commited image.
if test -n "${BEAST_MODE:-}"; then
  if test "$BEAST_MODE" == "$CONTAINER_NAME"; then
    e_echo '$BEAST_MODE should be image name, not container name!'
    exit 1
  fi
  e_echo 'replacing the container based on $BEAST_MODE image.'
  IMAGE_NAME="$BEAST_MODE"
  docker rm -f "$CONTAINER_NAME"
fi

# Check whether we have to pull the image.
if test -n "${PULL_IMG:-}"; then
  I="$PULL_IMG"
  docker pull "$I"
  docker tag "$I" "$IMAGE_NAME"
fi

# Or build it ourselves.
if test -n "$DOCKER_BUILD"; then
  pushd "$GPDB_SRC" || exit 1
  docker build \
    -f "$GPDB_SRC/arenadata/Dockerfile.ubuntu" \
    --progress plain \
    -t "$IMAGE_NAME" \
    "$GPDB_SRC"
  popd || exit 1
fi

if ! docker inspect "$IMAGE_NAME" > /dev/null 2>&1; then
  e_echo 'ERROR: no image to use. Set $PULL_IMG to image URL or $DOCKER_BUILD to anything to build the image from Dockerfile.' >&2
  exit 1
fi

AUX_DIR="$ENV_DIR/aux"

# A command which will be executed upon the creation of the container.
SETUP_CMD="$(cat "$AUX_DIR/image-setup.sh")"

# Create the container if it does not exist.
if ! docker container inspect "$CONTAINER_NAME" > /dev/null 2>&1; then
  P="$PORT_PREFIX"
  PV="$PORT_VARIATION"

  docker run -it --privileged -d \
    --sysctl 'kernel.sem=500 1024000 200 4096' \
    --sysctl 'net.unix.max_dgram_qlen=4096' \
    --cgroupns=host \
    -v "/public:/public:rw" \
    -v "$AUX_DIR/:/home/gpadmin/container-scripts:rw" \
    -v "$SRC_DIR:/home/gpadmin/host-sources:rw" \
    -v "$SRC_DIR/$GPDB_SUBDIR:/home/gpadmin/gpdb_src:rw" \
    -v "$SRC_DIR/$GPDB_SUBDIR/src/test:/home/gpadmin/gpdb_src/src/test:rw" \
    -v "$HOME/.tmux.conf:/etc/tmux.conf:rw" \
    -p "127.0.0.1:${PV}000-${PV}100:${P}000-${P}100" \
    -h "$CONTAINER_NAME" --name "$CONTAINER_NAME" "$IMAGE_NAME"

  docker start "$CONTAINER_NAME"

  if test -z "${BEAST_MODE:-}"; then
    if ! docker exec "$CONTAINER_NAME" bash -c "$SETUP_CMD"; then
      e_echo "ERROR: unable to setup the container!" >&2
      docker rm -f "$CONTAINER_NAME"
      exit 1
    fi
  fi
else
  docker start "$CONTAINER_NAME"
fi

trap 'docker stop "$CONTAINER_NAME"' ERR EXIT
sleep 1

ENTRYPOINT_COMMAND="$(cat "$AUX_DIR/container-entrypoint.sh")"
e_exec docker exec -it "$CONTAINER_NAME" bash -c "$ENTRYPOINT_COMMAND"
