#!/usr/bin/env bash
set -euo pipefail

# Prepare temp passwd/group files
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/tmp/group
getent passwd >"$NSS_WRAPPER_PASSWD" || true
getent group  >"$NSS_WRAPPER_GROUP"  || true

uid=$(id -u)
gid=$(id -g)
user="${NB_USER:-jovyan}"
home="/home/${user}"

# If our random UID isn’t in passwd, add it
if ! getent passwd "$uid" >/dev/null; then
  echo "${user}:x:${uid}:${gid}:,,,:${home}:/bin/bash" >>"$NSS_WRAPPER_PASSWD"
fi

# Ensure all supplementary groups have names
for g in $(id -G); do
  if ! getent group "$g" >/dev/null; then
    echo "group${g}:x:${g}:" >>"$NSS_WRAPPER_GROUP"
  fi
done

export LD_PRELOAD=libnss_wrapper.so
exec tini -g -- "$@"
