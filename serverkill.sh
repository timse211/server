#!/bin/bash

systemctl stop nfs
systemctl stop nfslock
systemctl stop rpcbind
systemctl stop vsftpd
yum remove nfs-utils rpcbind vsftpd -y
echo -e "all server is stop and remove"