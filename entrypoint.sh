#!/bin/bash
set -euo pipefail

echo "daemon=1
maxconnections=${MAX_CONNECTIONS}
rpcuser=${RPC_USER}
rpcpassword=${RPC_PASSWORD}
rpcallowip=${RPC_ALLOW_IP}
rpcport=${RPC_PORT}
port=${NODE_PORT}" > data/namecoin/namecoin.conf

exec "$@"
