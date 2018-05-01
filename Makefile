ifndef HTTP_PORT 
	HTTP_PORT=80
endif

ifndef RPC_PORT 
	RPC_PORT=8339
endif

ifndef PORT 
	PORT=8338
endif


DOCKER_RUN=sudo docker run -t
DOCKER_MAINNET=$(DOCKER_RUN)  -p $(HTTP_PORT):3000 -p $(PORT):8338 -p $(RPC_PORT):8339 -v doichain_main:/home/doichain/data --name=doichain-mainnet --hostname=doichain-mainnet
DOCKER_TESTNET=$(DOCKER_RUN) -e TESTNET=true  -p $(HTTP_PORT):3000 -p $(PORT):18338 -p $(RPC_PORT):18339 -v doichain_testnet:/home/doichain/data --name=doichain-testnet --hostname=doichain-testnet
DOCKER_REGTEST =$(DOCKER_RUN) -e REGTEST=true -p $(HTTP_PORT):3000 -p $(PORT):18445 -p $(RPC_PORT):18443 -v $@:/home/doichain/data --name=$@ --hostname=$@

#-f status=exited
RUNNING_TARGET=$(shell docker ps -aq -f name=$@)
PORT_EXISTS=$(shell lsof -i:$(HTTP_PORT) | grep LISTEN | wc -l)

IMG=inspiraluna/doichain
RUN_SHELL=bash

default: help

help:
	$(info Usage: make <mainnet|testnet|regtest-alice|regtest-bob|regtest-*> HTTP_PORT=<http-port>)
	$(info        make test)


port:
ifeq ($(strip ${PORT_EXISTS}),1) 
		$(info http port seems already in use!  ${PORT_EXISTS}) 
		exit 1 ;
else
		$(info http port $(HTTP_PORT) seems free - truyin to use it...)
endif

build:
	sudo docker build -t $(IMG) .
	
bob_rm:
	sudo docker rm -f doichain-bob

testnet_rm:
	sudo docker rm -f doichain-testnet

mainnet_rm:
	sudo docker rm -f doichain-mainnet

regtest%: port
	$(info creating $@) 
ifdef RUNNING_TARGET
		$(info       running s$(RUNNING_TARGET)s)
		docker rm -f $(RUNNING_TARGET)
endif
	$(DOCKER_REGTEST) -i $(IMG) 


bob-regtest: bob_rm build
	$(DOCKER_BOB) -i $(IMG) 

testnet: testnet_rm build
	$(DOCKER_TESTNET) -i $(IMG) 

mainnet: mainnet_rm build
	$(DOCKER_MAINNET) -i $(IMG)

regtest: alice-regtest bob-regtest

test: 
	#curl connect to RCP of alice and create new doichain address
	#curl generate 110 new blocks and send it to generated doichain address
	#curl connect to RPC of bob and create new doichain address
	#curl connect to RPC of alice and send 10 doicoins to bob
	#curl to alice dapp and autenticate, get userId and token
	#curl to alice dapp and add new opt-in
	#curl to alice RPC and check if transaction was created
	#curl to bob RPC and check if transaction already arrived
	#check email server if email arrived confirm email
	#curl to alice RPC and generate 1 new block
	#curl to bob and check if name_list contains new doi


