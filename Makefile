ifndef HTTP_PORT 
	MAINNET_HTTP_PORT=80
else
	MAINNET_HTTP_PORT=HTTP_PORT
endif
ifndef HTTP_PORT 
TESTNET_HTTP_PORT=81
else
	TESTNET_HTTP_PORT=HTTP_PORT
endif
ifndef HTTP_PORT
	REGTEST_HTTP_PORT_ALICE=83
else
	REGTEST_HTTP_PORT_ALICE=HTTP_PORT
endif
ifndef HTTP_PORT
	REGTEST_HTTP_PORT_BOB=84
else
	REGTEST_HTTP_PORT_BOB=HTTP_PORT
endif


DOCKER_RUN=sudo docker run -t
DOCKER_MAINNET=$(DOCKER_RUN)  -p $(MAINNET_HTTP_PORT):3000 -p 8338:8338 -p 8339:8339 -v doichain_main:/home/doichain/data --name=doichain-mainnet --hostname=doichain-mainnet
DOCKER_TESTNET=$(DOCKER_RUN) -e TESTNET=true  -p $(TESTNET_HTTP_PORT):3000 -p 18338:18338 -p 18339:18339 -v doichain_testnet:/home/doichain/data --name=doichain-testnet --hostname=doichain-testnet
DOCKER_REGTEST =$(DOCKER_RUN) -e REGTEST=true -p $(REGTEST_HTTP_PORT_BOB):3000 -p 19445:18445 -p 19443:18443 -v $@:/home/doichain/data --name=$@ --hostname=$@

DOCKER_ALICE=$(DOCKER_RUN) -e REGTEST=true -p $(REGTEST_HTTP_PORT_ALICE):3000 -p 18445:18445 -p 18443:18443 -v doichain_regtest_alice:/home/doichain/data --name=$@ --hostname=$@

DOCKER_BOB  =$(DOCKER_RUN) -e REGTEST=true -p $(REGTEST_HTTP_PORT_BOB):3000 -p 19445:18445 -p 19443:18443 -v doichain_regtest_bob:/home/doichain/data --name=doi-regtest-bob --hostname=doi-regtest-bob

RUNNING_TARGET=$(shell docker ps -aq -f status=exited -f name=$@)

IMG=inspiraluna/doichain
RUN_SHELL=bash

help:
	$(info Usage: make <mainnet|testnet|alice-regtest|bob-regtest> HTTP_PORT=<http-port>)
	$(info        make test)

	
	#if [ -z "$(docker ps -aq -f status=exited -f name=$(target))" ]; then \
    #  @echo "container running "$(target); \
    #else \
    #  œecho $(target)" not running";sudo docker rm -f $(target) ; \
  	#fi

build:
	sudo docker build -t $(IMG) .
	
bob_rm:
	sudo docker rm -f doichain-bob

testnet_rm:
	sudo docker rm -f doichain-testnet

mainnet_rm:
	sudo docker rm -f doichain-mainnet

regtest%:
	$(info creating $@) 
ifdef RUNNING_TARGET
	$(info       running)
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


