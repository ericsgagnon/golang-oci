# Extends golang with oracle instant client:
# 1. oracle instant client with oci
# 2. golang

ARG   OIC_VERSION=18.5
ARG   GOLANG_VERSION=1.12

# Oracle Instant Client (oci) ########################################################################
#
# https://github.com/oracle/docker-images/blob/master/OracleInstantClient/dockerfiles/18.3.0/Dockerfile
#
# LICENSE UPL 1.0
#
# Copyright (c) 2014-2018 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
#
# Dockerfile template for Oracle Instant Client
#
# HOW TO BUILD THIS IMAGE
# -----------------------
#
# Run:
#      $ docker build -t oracle/instantclient:18.3.0 .
#
#
FROM oraclelinux:7-slim as oracle-instant-client

ARG  OIC_VERSION
ARG  GOLANG_VERSION

RUN  curl -o /etc/yum.repos.d/public-yum-ol7.repo https://yum.oracle.com/public-yum-ol7.repo && \
     yum-config-manager --enable ol7_oracle_instantclient && \
     yum -y install oracle-instantclient$OIC_VERSION-basic oracle-instantclient$OIC_VERSION-devel oracle-instantclient$OIC_VERSION-sqlplus && \
     rm -rf /var/cache/yum



# Golang ############################################################################################
FROM golang:${GOLANG_VERSION} as golang

ARG  OIC_VERSION
ARG  GOLANG_VERSION

ENV  OIC_VERSION=${OIC_VERSION}
ENV  GOLANG_VERSION=${GOLANG_VERSION}


COPY --from=oracle-instant-client  /usr/lib/oracle /usr/lib/oracle
COPY --from=oracle-instant-client  /usr/share/oracle /usr/share/oracle
COPY --from=oracle-instant-client  /usr/include/oracle /usr/include/oracle
COPY ./oci8.pc /usr/lib/pkgconfig/oci8.pc


RUN  sed -i 's/OIC_VERSION/'"$OIC_VERSION"'/' /usr/lib/pkgconfig/oci8.pc && \
     apt update && apt install \
     libaio1

RUN  ln -s /lib64 /usr/lib64 && \
     echo /usr/lib/oracle/$OIC_VERSION/client64/lib > /etc/ld.so.conf.d/oracle-instantclient$OIC_VERSION.conf && \
     ldconfig

ENV PATH=$PATH:/usr/lib/oracle/$OIC_VERSION/client64/bin
