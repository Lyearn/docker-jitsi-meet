ARG JITSI_REPO=lyearn-jitsi
ARG BASE_TAG=centos-7
FROM ${JITSI_REPO}/base:${BASE_TAG}

RUN mkdir -p /usr/share/man/man1 && \
    apt-dpkg-wrap yum install -y java-11-openjdk