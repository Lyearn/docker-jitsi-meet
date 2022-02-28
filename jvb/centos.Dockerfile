ARG JITSI_REPO=lyearn-jitsi
ARG BASE_TAG=centos-7
FROM ${JITSI_REPO}/base-java:${BASE_TAG}

LABEL org.opencontainers.image.title="Jitsi Videobridge (jvb)"
LABEL org.opencontainers.image.description="WebRTC compatible server designed to route video streams amongst participants in a conference."
LABEL org.opencontainers.image.url="https://jitsi.org/jitsi-videobridge/"
LABEL org.opencontainers.image.source="https://github.com/jitsi/docker-jitsi-meet"
LABEL org.opencontainers.image.documentation="https://jitsi.github.io/handbook/"

RUN apt-dpkg-wrap yum install -y jq curl iproute unzip bind-utils

COPY rootfs/ /

RUN mkdir -p /usr/share/jitsi-videobridge && \
    unzip -d /usr/share/jitsi-videobridge /defaults/jitsi-videobridge.zip && \
    mv /usr/share/jitsi-videobridge/jitsi-videobridge-2.1-SNAPSHOT/* /usr/share/jitsi-videobridge && \
    rm -r /usr/share/jitsi-videobridge/jitsi-videobridge-2.1-SNAPSHOT

VOLUME /config
