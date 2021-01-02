#!/usr/bin/env bash
sudo cp -u -p /run/ejabberd.yml /usr/local/ejabberd/conf
sudo cp -u -p /run/auth_osp.py /usr/local/ejabberd/conf

# Configure ejabberd
export EJABBERD_DOMAIN
sed -i "s/CHANGEME/$EJABBERD_DOMAIN/g" /usr/local/ejabberd/conf/ejabberd.yml

export OSP_API_PROTOCOL
export OSP_API_DOMAIN

sed -i "s/protocol = \"http\"/protocol=\"$OSP_API_PROTOCOL\"/g" /usr/local/ejabberd/conf/auth_osp.py
sed -i "s/ospAPIServer = \"127.0.0.1:5010\"/ospAPIServer=\"$OSP_API_DOMAIN\"/g" /usr/local/ejabberd/conf/auth_osp.py

echo 'Starting Ejabberd'
supervisord --nodaemon --configuration /run/supervisord.conf