FROM alpine:latest
MAINTAINER David Lockwood

ARG OSP_VERSION="0.8.2"

ARG NGINX_VERSION=1.17.3
ARG NGINX_RTMP_VERSION=1.2.1

ARG DEFAULT_COREIP="127.0.0.1"
ARG DEFAULT_RTMPIP="127.0.0.1"

ARG DEFAULT_TZ="ETC/UTC"

ENV OSPCOREIP=$DEFAULT_COREIP
ENV OSPRTMPIP=$DEFAULT_RTMPIP

EXPOSE 1935/tcp

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

RUN apk add --no-cache tzdata

ENV TZ=$DEFAULT_TZ

RUN apk add --no-cache bash

# Download OSP from Repo
RUN cd /tmp && \
  wget "https://gitlab.com/Deamos/flask-nginx-rtmp-manager/-/archive/beta6d/flask-nginx-rtmp-manager-${OSP_VERSION}.tar.gz" && \
  tar zxf flask-nginx-rtmp-manager-${OSP_VERSION}.tar.gz && \
  rm flask-nginx-rtmp-manager-${OSP_VERSION}.tar.gz

# Make OSP Install Directory
RUN mkdir -p /opt/osp-edge
RUN cp /tmp/flask-nginx-rtmp-manager/installs/osp-edge /opt/osp-edge/

# Transfer OSP Docker Files
COPY entrypoint.sh /opt/osp-edge
COPY supervisord.conf /opt/osp-edge
COPY wait-for-it.sh /opt/osp-edge

# Create the www-data user
RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

# Set the OSP directory to www-data
RUN chown -R www-data:www-data /opt/osp-rtmp

# Download NGINX
RUN cd /tmp && \
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz

# Download the NGINX-RTMP Module
RUN cd /tmp && \
  wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz && \
  tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz

RUN cd /tmp && \
  wget "https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/master.tar.gz" && \
  tar xxf master.tar.gz

# Compile NGINX with the NGINX-RTMP Module
RUN cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure \
  --with-http_ssl_module \
  --with-http_v2_module \
  --with-http_auth_request_module \
  --with-cc-opt="-Wimplicit-fallthrough=0" \
  --add-module=../nginx-rtmp-module-${NGINX_RTMP_VERSION} \
  --add-module=../nginx-goodies-nginx-sticky-module-ng-08a395c66e42 && \
  cd /tmp/nginx-${NGINX_VERSION} && make && make install

RUN rm -rf /tmp/nginx-${NGINX_VERSION}

# Configure NGINX
RUN mkdir /usr/local/nginx/conf/locations
RUN mkdir /usr/local/nginx/conf/servers
RUN mkdir /usr/local/nginx/conf/services
RUN cp /tmp/flask-nginx-rtmp-manager/installs/nginx-core/nginx.conf /usr/local/nginx/conf/
RUN cp /tmp/flask-nginx-rtmp-manager/installs/nginx-core/mime.types /usr/local/nginx/conf/
RUN cp /tmp/flask-nginx-rtmp-manager/installs/osp-edge/setup/nginx/locations/* /usr/local/nginx/conf/locations
RUN cp /tmp/flask-nginx-rtmp-manager/installs/osp-edge/setup/nginx/servers/* /usr/local/nginx/conf/servers
RUN cp /tmp/flask-nginx-rtmp-manager/installs/osp-edge/setup/nginx/services/* /usr/local/nginx/conf/services


# Install Python, Gunicorn, and uWSGI
RUN apk add python3 \
  py3-pip \
  py3-setuptools \
  python3-dev \
  py3-gunicorn \
  uwsgi-python3

# Upgrade PIP
RUN pip3 install --upgrade pip

# Install OSP Dependancies
RUN pip3 install cryptography

# Setup FFMPEG for recordings and Thumbnails
RUN apk add ffmpeg

# Add Dialog (used in osp-config.sh)
RUN apk add dialog

# Setup Wait-For-It Script
RUN chmod +x /opt/osp-rtmp/wait-for-it.sh

# Install Supervisor
RUN apk add supervisor
RUN mkdir -p /var/log/supervisor

VOLUME ["/var/www", "/usr/local/nginx/conf"]

RUN chmod +x /opt/osp-rtmp/entrypoint.sh
ENTRYPOINT ["/bin/sh","-c", "/opt/osp-edge/entrypoint.sh"]
