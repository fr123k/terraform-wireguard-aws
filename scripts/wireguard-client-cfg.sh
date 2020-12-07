#!/bin/bash

cat > ./tmp/wg0.conf << EOF
[Interface]
Address = 10.8.0.2/32
PrivateKey = $(cat ./tmp/client_privatekey)

[Peer]
PublicKey = $(cat ./tmp/server_publickey)
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $(terraform output -json wireguard_eip | jq -r ".[${SERVER_INDEX}]"):51820
PersistentKeepalive = 25
EOF
