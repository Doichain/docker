#!/bin/bash
set -euo pipefail

echo "daemon=1
maxconnections=${MAX_CONNECTIONS}
rpcuser=${RPC_USER}
rpcpassword=${RPC_PASSWORD}
rpcallowip=${RPC_ALLOW_IP}
rpcport=${RPC_PORT}
port=${NODE_PORT}" > data/namecoin/namecoin.conf

DAPP_SETTINGS='{
  "app": {
    "types": ['
if [ $DAPP_SEND = true ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"send"'
  if [ $DAPP_CONFIRM = true ] || [ $DAPP_VERIFY = true ]; then 
	DAPP_SETTINGS=$DAPP_SETTINGS','
  fi
fi
if [ $DAPP_CONFIRM = true ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"confirm"'
  if [ $DAPP_VERIFY = true ]; then 
	DAPP_SETTINGS=$DAPP_SETTINGS','
  fi
fi
if [ $DAPP_VERIFY = true ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"verify"'
fi
DAPP_SETTINGS=$DAPP_SETTINGS']
  },'
  
  
if [ $DAPP_SEND = true ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"send": {
	"namecoin": {
      "host": "localhost",
      "port": "'$RPC_PORT'",
      "username": "'$RPC_USER'",
      "password": "'$RPC_PASSWORD'"
    }
  }'
  if [ $DAPP_CONFIRM = true ] || [ $DAPP_VERIFY = true ]; then 
	DAPP_SETTINGS=$DAPP_SETTINGS','
  fi
fi
if [ $DAPP_CONFIRM = true ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"confirm": {
	"namecoin": {
      "host": "localhost",
      "port": "'$RPC_PORT'",
      "username": "'$RPC_USER'",
      "password": "'$RPC_PASSWORD'"
    }
  }'
  if [ $DAPP_VERIFY = true ]; then 
	DAPP_SETTINGS=$DAPP_SETTINGS','
  fi
fi
if [ $DAPP_VERIFY = true ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"verify": {
	"namecoin": {
      "host": "localhost",
      "port": "'$RPC_PORT'",
      "username": "'$RPC_USER'",
      "password": "'$RPC_PASSWORD'"
    }
  }'
fi
DAPP_SETTINGS=$DAPP_SETTINGS'}'

echo $DAPP_SETTINGS > data/dapp/settings.json

exec "$@"