#!/bin/bash
#
# Nico Krause (nico@le-space.de)
#
# This bash script gets called by the doichain-wallet when a new block arrives.
# As soon the difficulty of a block is higher then 1000 we change 'consensus.nPowTargetTimespan' to 14 * 24 * 60 * 60 
# stop the node and do a make, make install and 
# start the node again with parameter -walletnotify=/home/doichain/data/.namecoin/normalise-difficulty.sh
myip=5.9.154.226
diff=0
goal=10
diffHighEnough=0
while [ $diffHighEnough -lt 1000 ]; do
     result=$(curl --user admin:generated-password --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getblockchaininfo", "params": [] }' -H 'content-type: text/plain;' http://$myip:8339/)

     if [[ $? -ne 0 ]]; then
      echo "failed with returncode $?"
      diff=0
      diffHighEnough=0
      echo $result
      continue
     else
       diff=$(echo $result |jq '.result.difficulty' | sed 'y/e/E/')
       echo "current difficulty is:"$diff 
	#echo 'if(1 == 2) print "true" else print "false"' | bc
       echo "call succeeded"$result
       #result=$(docker exec doichain_mainnet-alice namecoin-cli getblockchaininfo |jq '.difficulty')
       diffHighEnough=$(echo $diff'>'$goal | bc -l)
       if [[ $diffHighEnough == 1 ]]; then
       break;
       fi
       
      sleep 5	
     fi
 done
     if [[ "$" != 0 ]]; then

 echo "alice: changing nPowTargetTimeSpan and compiling this namecoind again" 
 docker exec -w /home/doichain/namecoin-core doichain_mainnet-alice sudo sed -i.bak -e "s/consensus.nPowTargetTimespan[[:space:]]=[[:space:]]0.4/consensus.nPowTargetTimespan = 15/g" src/chainparams.cpp
 docker exec -w /home/doichain/namecoin-core doichain_mainnet-alice sudo make
 docker exec -w /home/doichain/namecoin-core doichain_mainnet-alice namecoin-cli stop
 docker exec -w /home/doichain/namecoin-core doichain_mainnet-alice sudo make install
 docker exec doichain_mainnet-alice namecoind 

echo "bob: changing nPowTargetTimeSpan and compiling this namecoind again" 
docker exec -w /home/doichain/namecoin-core doichain_mainnet-bob sudo sed -i.bak -e "s/consensus.nPowTargetTimespan[[:space:]]=[[:space:]]0.4/consensus.nPowTargetTimespan = 15/g" src/chainparams.cpp
docker exec -w /home/doichain/namecoin-core doichain_mainnet-bob sudo make
docker exec -w /home/doichain/namecoin-core doichain_mainnet-bob namecoin-cli stop
docker exec -w /home/doichain/namecoin-core doichain_mainnet-bob sudo make install
docker exec doichain_mainnet-alice namecoind 

ALICE_DOCKER_IP=$(shell sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' doichain_mainnet-alice)
echo doichain_mainnet-alice has internal IP:$(ALICE_DOCKER_IP)
docker exec -w /home/doichain/namecoin-core doichain_mainnet-bob addnode $ALICE_DOCKER_IP onetry

echo "Now normalise nPowTargetTimespani again" 

fi
