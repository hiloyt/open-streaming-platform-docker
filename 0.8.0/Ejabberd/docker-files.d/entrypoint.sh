#!/usr/bin/env bash
sudo cp -u -p /run/ejabberd.yml /home/ejabberd/conf/ejabberd.yml
sudo cp -u -p /run/auth_osp.py /home/ejabberd/conf/auth_osp.py

# Configure ejabberd
export EJABBERD_DOMAIN
sed -i "s/CHANGEME/$EJABBERD_DOMAIN/g" /home/ejabberd/conf/ejabberd.yml

export OSP_API_PROTOCOL
export OSP_API_DOMAIN
export EJABBERD_PASSWORD

sed -i "s/protocol = \"http\"/protocol=\"$OSP_API_PROTOCOL\"/g" /home/ejabberd/conf/auth_osp.py
sed -i "s/ospAPIServer = \"127.0.0.1:5010\"/ospAPIServer=\"$OSP_API_DOMAIN\"/g" /home/ejabberd/conf/auth_osp.py

/home/ejabberd/bin/ejabberdctl -foreground