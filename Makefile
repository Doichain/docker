DOCKER_RUN=sudo docker run -t
DOCKER_MAINNET=$(DOCKER_RUN) -e REGTEST=true  -p 8338:8338 -p 8339:8339 --name=doichain-mainnet --hostname=doichain-mainnet
DOCKER_TESTNET=$(DOCKER_RUN) -e REGTEST=true  -p 18338:18338 -p 18339:18339 --name=doichain-testnet --hostname=doichain-testnet
DOCKER_ALICE=$(DOCKER_RUN) -e TESTNET=true -p 18445:18445 -p 18443:18443 --name=doichain-alice --hostname=doichain-alice
DOCKER_BOB  =$(DOCKER_RUN) -p 19445:18445 -p 19443:18443 --name=doichain-bob --hostname=doichain-bob

IMG=inspiraluna/doichain
RUN_SHELL=bash

build:
	sudo docker build -t $(IMG) .

alice_rm:
	sudo docker rm -f alice

bob_rm:
	sudo docker rm -f bob

alice_shell: build alice_rm
	$(DOCKER_ALICE) -i $(IMG) $(RUN_SHELL)

bob_shell: build bob_rm
	$(DOCKER_BOB) -i $(IMG) $(RUN_SHELL)

alice_daemon: build alice_rm
	$(DOCKER_ALICE) -d=true $(IMG) $(RUN_DAEMON)

bob_daemon: build bob_rm
	$(DOCKER_BOB) -d=true $(IMG) $(RUN_DAEMON)

testnet_rm:
	sudo docker rm -f doichain-testnet

mainnet_rm:
	sudo docker rm -f doichain-mainnet

testnet_shell: build testnet_rm
	$(DOCKER_TESTNET) -i $(IMG) $(RUN_SHELL)

mainnet_shell: build mainnet_rm
	$(DOCKER_MAINNET) -i $(IMG) $(RUN_SHELL)



