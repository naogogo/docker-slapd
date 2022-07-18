FROM library/debian:11

ARG DEBIAN_FRONTEND=noninteractive

RUN groupadd -g 10000 slapd \
 && useradd -d /nonexistent -g slapd -M -N -s /usr/sbin/nologin -u 10000 slapd \
 && apt-get update \
 && apt-get install --assume-yes --no-install-recommends \
      ldap-utils \
      slapd \
 && rm -rf \
      /etc/ldap/slapd.d \
      /run/slapd \
      /var/lib/apt/lists/* \
      /var/lib/ldap \
 && install -d -o slapd -g slapd -m 0700 \
      /etc/ldap/certs \
      /etc/ldap/init \
      /etc/ldap/slapd.d \
      /run/slapd \
      /var/lib/ldap

COPY --chown=root:root docker-entrypoint.sh /usr/local/bin/
COPY --chown=root:root schema /etc/ldap/schema/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["/usr/sbin/slapd", "-d", "none", "-F", "/etc/ldap/slapd.d", "-h", "ldapi:///"]

VOLUME ["/etc/ldap/certs", "/etc/ldap/init", "/etc/ldap/slapd.d", "/var/lib/ldap"]

USER slapd
