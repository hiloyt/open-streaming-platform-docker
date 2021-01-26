FROM ejabberd/ecs
MAINTAINER David Lockwood

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
RUN apk add --update python3 py3-pip
RUN pip3 install --upgrade pip
RUN pip install requests

USER ejabberd

RUN mkdir /home/ejabberd/files
COPY docker-files.d/entrypoint.sh /home/ejabberd/run/entrypoint.sh
COPY docker-files.d/ejabberd.yml /home/ejabberd/run/ejabberd.yml
COPY docker-files.d/auth_osp.py /home/ejabberd/run/auth_osp.py

COPY docker-files.d/inetrc /home/ejabberd/conf/inetrc

RUN chmod +x /home/ejabberd/run/entrypoint.sh
ENTRYPOINT ["/bin/sh","-c", "/home/ejabberd/run/entrypoint.sh"]