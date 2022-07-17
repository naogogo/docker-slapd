#!/bin/sh

set -eu

SLAPD_DATA_DIRECTORY=/var/lib/ldap
SLAPD_CONFIG_DIRECTORY=/etc/ldap/slapd.d

mkdir -p "${SLAPD_DATA_DIRECTORY}/accesslog"

if ! slapcat -F $SLAPD_CONFIG_DIRECTORY -n 0; then
  sed -E \
    -e "s|@DIRECTORY@|${SLAPD_DATA_DIRECTORY}|" \
    -e "s|@PROCESS@|gidNumber=$(id -g)+uidNumber=$(id -u),cn=peercred,cn=external,cn=auth|" \
    -e "s|@SUFFIX@|${SLAPD_SUFFIX}|" \
    /etc/ldap/init/slapd.ldif \
  | slapadd -F $SLAPD_CONFIG_DIRECTORY -n 0
fi

ulimit -n 1024

exec "$@"
