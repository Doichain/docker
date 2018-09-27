#ifndef HTTP_PORT 
#	HTTP_PORT=80
#endif
#
#ifndef RPC_PORT 
#	RPC_PORT=8339
#endif
#
#ifndef PORT 
#	PORT=8338
#endif

IMG=doichain/node-only

DOCKER_RUN=sudo docker run -td --restart always
private RUNNING_TARGET:=$(shell docker ps -aq -f name=$@)

RUN_SHELL=bash

default: check help

check:
	which jq; which bc

help:
	$(info Usage: make <mainnet|testnet|regtest-alice|regtest-bob|regtest-*> HTTP_PORT=<http-port>)
	$(info 		  make clean - removes $(IMG) image and containers)

all: build test

build:
	docker build --no-cache -t $(IMG) --build-arg DOICHAIN_VER=$(DOICHAIN_VER) --build-arg OS=$(OS) .
	
