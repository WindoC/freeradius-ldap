FROM ubuntu:22.04

ENV versoin=3.0.26

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
 apt-get install -y freeradius=$versoin* freeradius-utils=$versoin* freeradius-ldap=$versoin* \
 && rm -rf /var/lib/apt/lists/*

COPY rootfs /

RUN bash /scripts/setup.sh

# RADIUS Authentication Messages
EXPOSE 1812/udp

# # RADIUS Accounting Messages
# EXPOSE 1813/udp

ENTRYPOINT ["/scripts/entrypoint.sh"]
