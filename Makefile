ifndef MAINNET_HTTP_PORT 
MAINNET_HTTP_PORT=80
endif
ifndef TESTNET_HTTP_PORT 
TESTNET_HTTP_PORT=81
endif
ifndef REGTEST_HTTP_PORT_ALICE
REGTEST_HTTP_PORT_ALICE=83
endif
ifndef REGTEST_HTTP_PORT_BOB
REGTEST_HTTP_PORT_BOB=84
endif

DOCKER_RUN=sudo docker run -t
DOCKER_MAINNET=$(DOCKER_RUN)  -p $(MAINNET_HTTP_PORT):3000 -p 8338:8338 -p 8339:8339 -v doichain_main:/home/doichain/data --name=doichain-mainnet --hostname=doichain-mainnet
DOCKER_TESTNET=$(DOCKER_RUN) -e TESTNET=true  -p $(TESTNET_HTTP_PORT):3000 -p 18338:18338 -p 18339:18339 -v doichain_testnet:/home/doichain/data --name=doichain-testnet --hostname=doichain-testnet
DOCKER_ALICE=$(DOCKER_RUN) -e REGTEST=true -p $(REGTEST_HTTP_PORT_ALICE):3000 -p 18445:18445 -p 18443:18443 -v doichain_regtest_alice:/home/doichain/data --name=doi-regtest-alice --hostname=doi-regtest-alice
DOCKER_BOB  =$(DOCKER_RUN) -e REGTEST=true -p $(REGTEST_HTTP_PORT_BOB):3000 -p 19445:18445 -p 19443:18443 -v doichain_regtest_bob:/home/doichain/data --name=doi-regtest-bob --hostname=doi-regtest-bob

IMG=inspiraluna/doichain
RUN_SHELL=bash

build:
	sudo docker build -t $(IMG) .

alice_rm:
	sudo docker rm -f doichain-alice

bob_rm:
	sudo docker rm -f doichain-bob

testnet_rm:
	sudo docker rm -f doichain-testnet

mainnet_rm:
	sudo docker rm -f doichain-mainnet

alice-regtest: alice_rm build
	$(DOCKER_ALICE) -i $(IMG) 

bob-regtest: bob_rm build
	$(DOCKER_BOB) -i $(IMG) 

testnet: testnet_rm build
	$(DOCKER_TESTNET) -i $(IMG) 

mainnet: mainnet_rm build
	$(DOCKER_MAINNET) -i $(IMG)



