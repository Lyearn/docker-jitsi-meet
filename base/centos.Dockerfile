FROM centos:7

ARG JITSI_RELEASE=stable
ARG FREP_VERSION=1.3.11
ARG S6_OVERLAY_VERSION=3.0.0.2-2

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

COPY rootfs /

RUN apt-dpkg-wrap yum install -y ca-certificates gnupg wget


# Get Jitsi GPG key
RUN wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | gpg --dearmour | install -D /dev/stdin /etc/apt/trusted.gpg.d/jitsi.gpg

# Install frep
RUN wget -qO /usr/bin/frep https://github.com/subchen/frep/releases/download/v$FREP_VERSION/frep-$FREP_VERSION-linux-amd64

# Make frep executable
RUN chmod +x /usr/bin/frep

RUN [ "$JITSI_RELEASE" = "unstable" ] && \
    apt-dpkg-wrap yum install -y jq procps curl vim-enhanced iputils net-tools || \
    true

# Install s6 overlay
# RUN wget -qO - https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz | tar xfz - -C /

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch-${S6_OVERLAY_VERSION}.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64-${S6_OVERLAY_VERSION}.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch-${S6_OVERLAY_VERSION}.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch-${S6_OVERLAY_VERSION}.tar.xz /tmp

RUN tar -C / -Jxpf /tmp/s6-overlay-noarch-${S6_OVERLAY_VERSION}.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64-${S6_OVERLAY_VERSION}.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch-${S6_OVERLAY_VERSION}.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch-${S6_OVERLAY_VERSION}.tar.xz


RUN groupadd jitsi
RUN useradd jicofo -g jitsi
RUN useradd jvb -g jitsi
RUN useradd prosody -g jitsi


ENTRYPOINT [ "/init" ]