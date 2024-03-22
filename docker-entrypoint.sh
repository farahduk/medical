#!/bin/sh

CURR_UID=$(id -u)
CURR_GID=$(id -g)

USER_UID=$(id -u medical)
USER_GID=$(id -g medical)

GOSU_AVAILABLE=$(command -v gosu)

CMD=""

exists() {
  command -v "$1" >/dev/null 2>&1
}


# Properly expand the arguments of the computed command
CMD="${CMD} $@"

# If gosu is available (in development images) and we received a
# host user and group ids, let's create a group and user matching
# the given ids and drop privileges to them. This is useful when
# mounting volumes during development to avoid messing with file
# permissions on working directories.
if [ "$CURR_UID" = 0 ] && [[ $GOSU_AVAILABLE ]]; then
  RUN_UID=$USER_UID
  RUN_GID=$USER_GID

  if [[ $HOST_GID ]]; then
    addgroup -g $HOST_GID user 2>/dev/null
    RUN_GID=$HOST_GID
  fi

  if [[ $HOST_UID ]]; then
    adduser -Du $HOST_UID -G user user 2>/dev/null
    RUN_UID=$HOST_UID
  fi

  gosu $RUN_UID:$RUN_GID sh -c "${CMD}"
else
  ${CMD}
fi