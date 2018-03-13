#!/bin/bash
set -euo pipefail

echo "daemon=1
maxconnections=${MAX_CONNECTIONS}
rpcuser=${RPC_USER}
rpcpassword=${RPC_PASSWORD}
rpcallowip=${RPC_ALLOW_IP}
rpcport=${RPC_PORT}" > data/namecoin/namecoin.conf

DAPP_SETTINGS='{
  "app": {
    "types": ['
if [ $SEND_DAPP == 'true' ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"send"'
  if [ $CONFIRM_DAPP == 'true' ] || [ $VERIFY_DAPP == 'true' ]; then 
	DAPP_SETTINGS=$DAPP_SETTINGS','
  fi
fi
if [ $CONFIRM_DAPP == 'true' ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"confirm"'
  if [ $VERIFY_DAPP == 'true' ]; then 
	DAPP_SETTINGS=$DAPP_SETTINGS','
  fi
fi
if [ $VERIFY_DAPP == 'true' ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"verify"'
fi
DAPP_SETTINGS=$DAPP_SETTINGS']
  },'
  
  
if [ $SEND_DAPP == 'true' ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"send": {
	"namecoin": {
      "host": "localhost",
      "port": "'$RPC_PORT'",
      "username": "'$RPC_USER'",
      "password": "'$RPC_PASSWORD'"
    }
  }'
  if [ $CONFIRM_DAPP == 'true' ] || [ $VERIFY_DAPP == 'true' ]; then 
	DAPP_SETTINGS=$DAPP_SETTINGS','
  fi
fi
if [ $CONFIRM_DAPP == 'true' ]; then 
  DAPP_SETTINGS=$DAPP_SETTINGS'"confirm": {
	"namecoin": {
      "host": "localhost",
      "port": "'$RPC_PORT'",
      "username": "'$RPC_USER'",
      "password": "'$RPC_PASSWORD'"
    }
  }'
  if [ $VERIFY_DAPP == 'true' ]; then 
	DAPP_SETTINGS=$DAPP_SETTINGS','
  fi
fi
if [ $VERIFY_DAPP == 'true' ]; then 
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