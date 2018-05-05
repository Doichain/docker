ifndef HTTP_PORT 
	HTTP_PORT=80
endif

ifndef RPC_PORT 
	RPC_PORT=8339
endif

ifndef PORT 
	PORT=8338
endif

#in case you want to play with alice and bob - change those parameters!
HTTP_PORT_ALICE=84
HTTP_PORT_BOB=85

RPC_PORT_ALICE=18339
RPC_PORT_BOB=28339

PORT_ALICE=18338
PORT_BOB=28338

THIS_FILE := $(lastword $(MAKEFILE_LIST))

DOCKER_RUN=sudo docker run -td
DOCKER_MAINNET=$(DOCKER_RUN) -p $(HTTP_PORT):3000 -p $(PORT):8338 -p $(RPC_PORT):8339 -v doichain_main:/home/doichain/data --name=doichain-mainnet --hostname=doichain-mainnet
DOCKER_TESTNET=$(DOCKER_RUN) -e TESTNET=true -p $(HTTP_PORT):3000 -p $(PORT):18338 -p $(RPC_PORT):18339 -v doichain_testnet:/home/doichain/data --name=doichain-testnet --hostname=doichain-testnet
DOCKER_REGTEST=$(DOCKER_RUN) -e REGTEST=true -e RPC_ALLOW_IP=::/0 -p $(HTTP_PORT):3000 -p $(PORT):18445 -p $(RPC_PORT):18332 -v $@:/home/doichain/data --name=$@ --hostname=$@

private RUNNING_TARGET:=$(shell docker ps -aq -f name=$@)

HTTPPORT_EXISTS:=$(shell sudo lsof -i:$(HTTP_PORT) | grep LISTEN) #cannot recognise my webserver for some reason
RPCPORT_EXISTS:=$(shell sudo lsof -i:$(RPC_PORT) | grep LISTEN) #cannot recognise my webserver for some reason
P2PPORT_EXISTS:=$(shell sudo lsof -i:$(PORT) | grep LISTEN) #cannot recognise my webserver for some reason

IMG=inspiraluna/doichain
RUN_SHELL=bash

default: check help

check:
	which jq

compile:
	docker build -t $(IMG):latest .


help:
	$(info Usage: make <mainnet|testnet|regtest-alice|regtest-bob|regtest-*> HTTP_PORT=<http-port>)
	$(info 		  make clean - removes $(IMG) the images and container - must be build again
	$(info        make test - creates a regtest network, connects alice and bob, generates 110 blocks, sends 10 to bob)
	$(info        make test_rm - deletes regtest containers - but leaves volumes untouched)
	$(info        make all - compile and test )
	$(info        connect-alice-to-bob - connect alice with bob in regtest network)
	$(info 		  generate-110 - generate 110 blocks in regtest network)
	$(info 		  send-10-to-bob - send 10 doi to bob)
	$(info 		  name_doi - test name_doi)


http_port:
	$(info checking port $(HTTP_PORT) -$(filter-out \ , $(strip ${HTTPPORT_EXISTS}))-) 
ifeq ($(filter-out \ , $(strip ${HTTPPORT_EXISTS})), ) 
	$(info http port $(HTTP_PORT) seems free - truying to use it...)
else
	$(info http port $(HTTP_PORT) seems already in use - e.g. use HTTP_PORT=<http-port> !)
	exit 1 ;
endif

rpc_port:
	$(info checking rpc-port $(RPC_PORT) -$(filter-out \ , $(strip ${RPCPORT_EXISTS}))-) 
ifneq ($(filter-out \ , $(strip ${RPCPORT_EXISTS})), )  
		$(info rpc port seems already in use!  ${RPC_PORT}) 
		exit 1 ;
else
		$(info rpc port $(RPC_PORT) seems free - truying to use it...)
endif

p2pport:
	$(info checking p2p-port $(PORT) -$(filter-out \ , $(strip ${P2PPORT_EXISTS}))-) 
ifneq ($(filter-out \ , $(strip ${P2PPORT_EXISTS})), )  
		$(info p2p port seems already in use!  ${PORT}) 
		exit 1 ;
else
		$(info p2p port $(PORT) seems free - truying to use it...)
endif

all: build test

build:
	sudo docker build -t $(IMG) .
	
testnet_rm:
	sudo docker rm -f doichain-testnet

mainnet_rm:
	sudo docker rm -f doichain-mainnet

regtest%: http_port rpc_port p2pport
	$(info -$(RUNNING_TARGET)-) 
ifneq ($(RUNNING_TARGET),)  	
	$(info running: -$(RUNNING_TARGET)-) 
	docker rm -f $(RUNNING_TARGET) 
endif 
	$(DOCKER_REGTEST) -i $(IMG) 

testnet: build
	$(DOCKER_TESTNET) -i $(IMG) 

mainnet: build
	$(DOCKER_MAINNET) -i $(IMG)

test_rm:
	docker rm -fv regtest-bob regtest-alice 

clean: 
	docker rmi -f $(IMG)

connect-alice-to-bob:
	#get internal docker ipaddress of alice and let bob connect to alice
	$(eval ALICE_DOCKER_IP=$(shell sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' regtest-alice))
	@echo regtest-alice has internal IP:$(ALICE_DOCKER_IP)
	curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "addnode", "params": ["$(ALICE_DOCKER_IP)", "onetry"] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_BOB)/

generate-110:
	#generate new addresses on alice and bob
	#generating 110 blocks on alice
	$(eval ALICE_NEW_ADDRESS=$(shell curl --silent --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getnewaddress", "params": [""] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_ALICE)/ | jq .result))
	$(eval BOB_NEW_ADDRESS=$(shell curl --silent --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getnewaddress", "params": [""] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_BOB)/ | jq .result))
	
	curl --silent --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "generatetoaddress", "params": [110,$(ALICE_NEW_ADDRESS)] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_ALICE)/ | jq '.result'

send-10-to-bob:
	$(eval BOB_ADDRESS=$(shell curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getaddressesbyaccount", "params": [""] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_BOB)/ | jq '.result[0]'))
	$(eval ALICE_ADDRESS=$(shell curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getaddressesbyaccount", "params": [""] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_ALICE)/ | jq '.result[0]'))
	
	$(eval ismine=$(shell curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "validateaddress", "params": [$(BOB_ADDRESS)] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_BOB)/ | jq '.result.ismine'))
	$(info bobs doichain address: $(BOB_ADDRESS) ismine: $(ismine))

	$(eval txid=$(shell curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "sendtoaddress", "params": [$(BOB_ADDRESS),10] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_ALICE)/ | jq '.result' ))
	$(info 10 dois send to bob: ($(BOB_ADDRESS)) with txid: $(txid))
	#mine another block so the transaction can arrive
	curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "generatetoaddress", "params": [1,$(ALICE_ADDRESS)] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_ALICE)/ | jq '.result'
	curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getbalance", "params": [] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_ALICE)/ | jq '.result'
	curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getbalance", "params": [] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_BOB)/ | jq '.result'

name_doi:
	#create example name_doi on alice and send it to bob
	$(eval currentTime=$(shell date +%s))
	$(eval BOB_ADDRESS=$(shell curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getaddressesbyaccount", "params": [""] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_BOB)/ | jq '.result[0]'))
	$(eval ALICE_ADDRESS=$(shell curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getaddressesbyaccount", "params": [""] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_ALICE)/ | jq '.result[0]'))
	$(info bobs address is:($(BOB_ADDRESS)))
	$(eval txid_fee=$(shell curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "sendtoaddress", "params": [$(BOB_ADDRESS),0.02] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_ALICE)/ | jq '.result' ))
	$(info sent 0.02 to Bob txid:($(txid_fee)))
	$(eval txid_doi=$(shell curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "name_doi", "params": ["e/maketest_$(currentTime)","{testparam:testval}",$(BOB_ADDRESS)] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_ALICE)/ | jq '.result' ))
	$(info sent new name_doi to Bob txid:($(txid_doi)))
	sleep 3
	
	#check if transaction already arrived at bobs
	$(eval txid_fee_result=$(shell curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getrawtransaction", "params": ["$(txid_fee)", 1] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_BOB)/ | jq '.result.vout.scriptPubKey.nameOp' ))
	$(info doi transaction arrived?  ($(txid_fee_result))) 
	$(eval txid_doi_result=$(shell curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getrawtransaction", "params": ["$(txid_doi)", 1] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_BOB)/ | jq '.result.vout.scriptPubKey.nameOp' ))
	$(info doi transaction arrived?  ($(txid_doi_result)))
	curl -s --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "generatetoaddress", "params": [1,$(ALICE_ADDRESS)] }' -H 'content-type: text/plain;' http://127.0.0.1:$(RPC_PORT_ALICE)/ | jq '.result'
	


test: 
	#starting regtest-alice on port 84 and RPC_PORT 18339 (with send-mode dapp)
	@$(MAKE) -e -f $(THIS_FILE) regtest-alice HTTP_PORT=$(HTTP_PORT_ALICE) RPC_PORT=$(RPC_PORT_ALICE) PORT=$(PORT_ALICE)
	#starting regtest-bob on port 85 and RPC_PORT 18339 (with confirm-mode and verify mode dapp)
	@$(MAKE) -e -f $(THIS_FILE) regtest-bob HTTP_PORT=$(HTTP_PORT_BOB) RPC_PORT=$(RPC_PORT_BOB) PORT=$(PORT_BOB)
	sleep 3
	@echo started alice and bob as doichain nodes!
	

	#curl connect to RCP of alice and create new doichain address
	#curl connect to RPC of bob and create new doichain address
	@$(MAKE) -e -f $(THIS_FILE) connect-alice-to-bob
	#curl generate 110 new blocks and send it to generated doichain address
	@$(MAKE) -e -f $(THIS_FILE) generate-110
	#curl connect to RPC of alice and send 10 doicoins to bob
	@$(MAKE) -e -f $(THIS_FILE) send-10-to-bob
	
	#test simple name-doi and send it to another addresss
	@$(MAKE) -j 1 -e -f $(THIS_FILE) name_doi

	##dApp tests
	#curl to alice dapp and autenticate, get userId and token
	#curl to alice dapp and add new opt-in
	#curl to alice RPC and check if transaction was created
	#curl to bob RPC and check if transaction already arrived
	#check email server if email arrived confirm email
	#curl to alice RPC and generate 1 new block
	#curl to bob and check if name_list contains new doi


