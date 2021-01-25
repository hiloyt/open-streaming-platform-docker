FROM alpine:latest
MAINTAINER David Lockwood

ARG EJABBERD_VERSION="20.12"
ARG NGINX_VERSION=1.17.3
ARG OSP_VERSION="0.8.3"
ARG DEFAULT_TZ="ETC/UTC"

ARG DEFAULT_EJABBERD_DOMAIN="stream.example.com"
ARG DEFAULT_EJABBERD_PASSWORD="CHANGEME"
ARG DEFAULT_OSP_API_PROTOCOL="http"
ARG DEFAULT_OSP_API_DOMAIN="stream.example.com"

ENV OSP_EJABBED_VERSION="0.8.3"
ENV EJABBERD_PASSWORD=DEFAULT_EJABBERD_PASSWORD
ENV EJABBERD_DOMAIN=$DEFAULT_EJABBERD_DOMAIN
ENV OSP_API_PROTOCOL=$DEFAULT_OSP_API_PROTOCOL
ENV OSP_API_DOMAIN=$DEFAULT_OSP_API_DOMAIN

USER root

# Get initial dependancies
RUN apk update
RUN apk add alpine-sdk \
  pcre-dev \
  libressl-dev \
  openssl-dev \
  libffi-dev \
  wget \
  git \
  linux-headers \
  zlib-dev \
  postgresql-dev \
  gcc \
  libgcc \
  musl-dev \
  jpeg-dev \
  zlib-dev

RUN apk add --update python3 py3-pip
RUN pip3 install --upgrade pip
RUN pip install requests

RUN apk add --no-cache tzdata

ENV TZ=$DEFAULT_TZ

RUN apk add --no-cache bash

# Transfer OSP Docker Files
RUN mkdir -p /run
COPY entrypoint.sh /run
COPY supervisord.conf /run

# Download OSP from Repo
#RUN cd /tmp && \
#  wget "https://gitlab.com/Deamos/flask-nginx-rtmp-manager/-/archive/${OSP_VERSION}/flask-nginx-rtmp-manager-${OSP_VERSION}.tar.gz" && \
#  git clone https://gitlab.com/Deamos/flask-nginx-rtmp-manager.git
#  tar zxf flask-nginx-rtmp-manager-${OSP_VERSION}.tar.gz && \
#  rm flask-nginx-rtmp-manager-${OSP_VERSION}.tar.gz

# Clone Branch Instead
RUN cd /tmp && git clone https://gitlab.com/Deamos/flask-nginx-rtmp-manager.git && cd flask-nginx-rtmp-manager

# Install Nginx Proxy
RUN cd /tmp && \
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz

# Compile NGINX with the NGINX-RTMP Module
RUN cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure \
  --with-http_ssl_module \
  --with-http_v2_module \
  --with-cc-opt="-Wimplicit-fallthrough=0" && \
  cd /tmp/nginx-${NGINX_VERSION} && make && make install

RUN rm -rf /tmp/nginx-${NGINX_VERSION}

RUN mkdir /usr/local/nginx/conf/locations
RUN cp /tmp/flask-nginx-rtmp-manager/installs/nginx-core/nginx.conf /usr/local/nginx/conf/locations/

# Install ejabberd
RUN wget -O /tmp/ejabberd-${EJABBERD_VERSION}-linux-x64.run "https://www.process-one.net/downloads/downloads-action.php?file=/${EJABBERD_VERSION}/ejabberd-${EJABBERD_VERSION}-linux-x64.run"
RUN chmod +x /tmp/ejabberd-${EJABBERD_VERSION}-linux-x64.run
RUN cd /tmp && ejabberd-${EJABBERD_VERSION}-linux-x64.run --unattendedmodeui none --mode unattended --prefix /usr/local/ejabberd --cluster 0
RUN mkdir /usr/local/ejabberd/conf

RUN cp /tmp/flask-nginx-rtmp-manager/installs/ejabberd/setup/ejabberd.yml /usr/local/ejabberd/conf/ejabberd.yml
RUN cp /tmp/flask-nginx-rtmp-manager/installs/ejabberd/setup/ejabberd.yml /run/ejabberd.yml
RUN cp /tmp/flask-nginx-rtmp-manager/installs/ejabberd/setup/inetrc /usr/local/ejabberd/conf/inetrc
RUN cp /tmp/flask-nginx-rtmp-manager/installs/ejabberd/setup/auth_osp.py /usr/local/ejabberd/conf/auth_osp.py
RUN cp /tmp/flask-nginx-rtmp-manager/installs/ejabberd/setup/nginx/locations/ejabberd.conf /usr/local/ejabberd/conf/auth_osp.py
RUN cp /tmp/flask-nginx-rtmp-manager/installs/ejabberd/setup/auth_osp.py /run/auth_osp.py

# Install Supervisor
RUN apk add supervisor
RUN mkdir -p /var/log/supervisor

RUN chmod +x /run/entrypoint.sh
ENTRYPOINT ["/bin/sh","-c", "/run/entrypoint.sh"]