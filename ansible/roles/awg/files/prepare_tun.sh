#!/bin/bash

TUN=${1}

NETS=${2}

DEL_LINE="$(cat -n /etc/amnezia/amneziawg/${TUN}.conf | grep AllowedIP | awk '{print $1}')"
if [ ! -z "${DEL_LINE}" ]; then
  sed -i "${DEL_LINE}d" "/etc/amnezia/amneziawg/${TUN}.conf"
fi

LINE_NUMBER=$(cat -n "/etc/amnezia/amneziawg/${TUN}.conf" | grep '\[Peer\]' | awk '{print $1}')

LINE_NUMBER=$((LINE_NUMBER+1))

NETS=$(readarray -t ARRAY < "/etc/amnezia/${NETS}";  printf -v TXT  "%s, " "${ARRAY[@]}"; echo "AllowedIPs = ${TXT%, }")

sed -i "${LINE_NUMBER}i ${NETS}" "/etc/amnezia/amneziawg/${TUN}.conf"
