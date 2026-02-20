#!/bin/bash

IP_ADDR=$(ip ad show dev $1 | grep -oP '(?<=inet )\S+(?=/)')

for NETWORK in $(cat /etc/amnezia/networks); do
  ip ro add $NETWORK via $IP_ADDR dev $1
done
