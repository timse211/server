#!/bin/bash

echo -e "NFS and remote agent rpc is installing...\n" &&
yum install rpcbind nfs-utils -y &&
systemctl start rpcbind && systemctl start nfs && systemctl start nfslock &&
echo -e "NFS and rpc is set and online\n" &&
echo -e "vsftp is installing...\n"
yum install vsftpd ftp -y &&
systemctl start vsftpd &&
echo -e "vsftp set and online\n"