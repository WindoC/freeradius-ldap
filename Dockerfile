FROM ubuntu:22.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive \
 apt-get install -y freeradius
RUN DEBIAN_FRONTEND=noninteractive \
 apt-get install -y freeradius-utils
RUN DEBIAN_FRONTEND=noninteractive \
 apt-get install -y freeradius-ldap
RUN rm -rf /var/lib/apt/lists/*

COPY rootfs /

RUN /scripts/setup.sh

# RADIUS Authentication Messages
EXPOSE 1812/udp

# RADIUS Accounting Messages
EXPOSE 1813/udp

ENTRYPOINT ["/scripts/entrypoint.sh"]
