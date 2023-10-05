#!/bin/bash

#Script para obter o status do serviço apache

SERVICO=httpd

STATUS=$(systemctl is-active $SERVICO)

MENSAGEM1="O $SERVICO está ONLINE"
MENSAGEM2="O $SERVICO está offline"

export LC_TIME=pt_BR.utf8

DATA=$(date '+%d de %B de %Y')
HORA=$(date '+%H:%M:%S')

if [ $STATUS == "active" ]; then
    echo "$DATA - $HORA" >> /mnt/nfs_share/elanonunes/online.txt
    echo "Status=$STATUS"  >> /mnt/nfs_share/elanonunes/online.txt
    echo "$MENSAGEM1" >> /mnt/nfs_share/elanonunes/online.txt
    echo "---------------------------------" >> /mnt/nfs_share/elanonunes/online.txt
else
    echo "$DATA - $HORA" >> /mnt/nfs_share/elanonunes/offline.txt
    echo "Status=$STATUS" >> /mnt/nfs_share/elanonunes/offline.txt
    echo "$MENSAGEM2" >> /mnt/nfs_share/elanonunes/offline.txt
    echo "---------------------------------" >> /mnt/nfs_share/elanonunes/offline.txt
fi