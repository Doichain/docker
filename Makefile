DOCKER_RUN=sudo docker run -t
DOCKER_MAINNET=$(DOCKER_RUN)  -p 8338:8338 -p 8339:8339 --name=doichain-mainnet --hostname=doichain-mainnet
DOCKER_TESTNET=$(DOCKER_RUN) -e TESTNET=true  -p 18338:18338 -p 18339:18339 --name=doichain-testnet --hostname=doichain-testnet
DOCKER_ALICE=$(DOCKER_RUN) -e REGTEST=true -p 18445:18445 -p 18443:18443 --name=doichain-alice --hostname=doichain-alice
DOCKER_BOB  =$(DOCKER_RUN) -e REGTEST=true -p 19445:18445 -p 19443:18443 --name=doichain-bob --hostname=doichain-bob

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

alice-regtest: build
	$(DOCKER_ALICE) -i $(IMG) 

bob-regtest: build
	$(DOCKER_BOB) -i $(IMG) 

testnet: build
	$(DOCKER_TESTNET) -i $(IMG) 

mainnet_shell: build
	$(DOCKER_MAINNET) -i $(IMG)



