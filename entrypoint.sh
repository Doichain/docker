#!/bin/bash
set -euo pipefail

_RPC_PORT=${RPC_PORT}
_NODE_PORT=${NODE_PORT}
if [ $REGTEST = true ]; then
	_RPC_PORT=$RPC_PORT_REGTEST
  _NODE_PORT=$NODE_PORT_REGTEST
fi

if [ -z "$RPC_USER" ] || [ -z "$RPC_PASSWORD" ]; then
	echo "RPC user or password not set! (ENV RPC_USER, RPC_PASSWORD)"
	exit 1
fi

echo "daemon=1
rpcuser=${RPC_USER}
rpcpassword=${RPC_PASSWORD}
rpcallowip=${RPC_ALLOW_IP}
rpcport=${_RPC_PORT}
port=${_NODE_PORT}" > data/namecoin/namecoin.conf

if [ $DAPP_SEND = false ] && [ $DAPP_CONFIRM = false ] && [ $DAPP_VERIFY = false ]; then
	echo "No dApp type is enabled. Please use at least one dApp type or use node-only container instead! (ENV DAPP_SEND, DAPP_CONFIRM, DAPP_VERIFY)"
	exit 1
fi
if [ -z "$DAPP_HOST" ]; then
	echo "No host settings found! (ENV DAPP_HOST)"
	exit 1
fi
DAPP_SETTINGS='{
  "app": {
		"debug": "'$DAPP_DEBUG'",
		"host": "'$DAPP_HOST'",
		"port": "'$DAPP_PORT'",
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
		"doiMailFetchUrl": "'$DAPP_DOI_URL'",
		"namecoin": {
	    "host": "localhost",
	    "port": "'$_RPC_PORT'",
	    "username": "'$RPC_USER'",
	    "password": "'$RPC_PASSWORD'"
	  }
  }'
  if [ $DAPP_CONFIRM = true ] || [ $DAPP_VERIFY = true ]; then
		DAPP_SETTINGS=$DAPP_SETTINGS','
  fi
fi
if [ $DAPP_CONFIRM = true ]; then
	if [ -z "$DAPP_SMTP_USER" ] || [ -z "$DAPP_SMTP_PASS" ] || [ -z "$DAPP_SMTP_HOST" ] || [ -z "$DAPP_SMTP_PORT" ]; then
		echo "Confirmation dApp active but smtp settings not found! (ENV DAPP_SMTP_USER, DAPP_SMTP_PASS, DAPP_SMTP_HOST, DAPP_SMTP_PORT)"
		exit 1
	fi
  DAPP_SETTINGS=$DAPP_SETTINGS'"confirm": {
		"namecoin": {
		  "host": "localhost",
		  "port": "'$_RPC_PORT'",
		  "username": "'$RPC_USER'",
		  "password": "'$RPC_PASSWORD'",
			"address": "'$CONFIRM_ADDRESS'"
		},
		"smtp": {
      "username": "'$DAPP_SMTP_USER'",
      "password": "'$DAPP_SMTP_PASS'",
      "server":   "'$DAPP_SMTP_HOST'",
      "port": "'$DAPP_SMTP_PORT'"
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
	    "port": "'$_RPC_PORT'",
	    "username": "'$RPC_USER'",
	    "password": "'$RPC_PASSWORD'"
	  }
  }'
fi
DAPP_SETTINGS=$DAPP_SETTINGS'}'
echo $DAPP_SETTINGS > data/dapp/settings.json

exec "$@"
