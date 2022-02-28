ARG JITSI_REPO=lyearn-jitsi
ARG BASE_TAG=centos-7

FROM ${JITSI_REPO}/base:${BASE_TAG} as builder

RUN apt-dpkg-wrap yum install -y epel-release

RUN rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7

RUN apt-dpkg-wrap yum install -y \
      lua \
      lua-devel \
      cyrus-sasl-devel \
      openssl-devel \
      luarocks \
      git \
      gcc \
      make

ADD https://luarocks.github.io/luarocks/releases/luarocks-3.8.0.tar.gz /tmp

RUN tar -zxf /tmp/luarocks-3.8.0.tar.gz --directory=/tmp && \
    cd /tmp/luarocks-3.8.0 && \
    ./configure --with-lua-include=/usr/include && \
    make && \
    make install

RUN luarocks install cyrussasl 1.1.0-1 && \
    luarocks install net-url 0.9-1 && \
    luarocks install luajwtjitsi 2.0-0

FROM ${JITSI_REPO}/base:${BASE_TAG}

LABEL org.opencontainers.image.title="Prosody IM"
LABEL org.opencontainers.image.description="XMPP server used for signalling."
LABEL org.opencontainers.image.url="https://prosody.im/"
LABEL org.opencontainers.image.source="https://github.com/jitsi/docker-jitsi-meet"
LABEL org.opencontainers.image.documentation="https://jitsi.github.io/handbook/"

ENV XMPP_CROSS_DOMAIN="false"

RUN apt-dpkg-wrap yum install -y epel-release
RUN rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7

RUN apt-dpkg-wrap yum install -y \
      prosody \
      openssl \
      libldap-common \
      sasl2-bin \
      libsasl2-modules-ldap \
      lua-basexx \
      lua-ldap \
      lua-sec \
      patch

COPY rootfs/ /

RUN patch -d /usr/lib64/prosody/modules/muc -p0 < /prosody-plugins/muc_owner_allow_kick.patch

COPY --from=builder /usr/local/lib/lua /usr/local/lib/lua
COPY --from=builder /usr/local/share/lua /usr/local/share/lua

EXPOSE 5222 5347 5280

VOLUME ["/config", "/prosody-plugins-custom"]
