#!/bin/bash
#
# Nico Krause (nico@le-space.de)
# This bash script gets called by the doichain-wallet when a new block arrives.
# as soon the difficulty of the block is higher then 1000 we change 'consensus.nPowTargetTimespan' to 14 * 24 * 60 * 60 
# stop the node and do a make, make install and 
# start the node again with parameter -walletnotify=/home/doichain/data/.namecoin/normalise-difficulty.sh
diff=$(namecoin-cli getblockchaininfo |jq '.difficulty' | sed 'y/e/E/')
goal=1000
diffHighEnough=$(echo $diff'>'$goal | bc -l)
echo $diffHighEnough
if ((1 == 1)); then
 echo "changing nPowTargetTimeSpan" 
 #sudo sed -i.bak 's/consensus.nPowTargetTimespan = 0.1 * 60 * 60; //testnet /consensus.nPowTargetTimespan = 14 * 24 * 60 * 60; //testnet /g' /home/doichain/namecoin-core/src/chainparams.cpp
 namecoin-cli stop
 #cd /home/doichain/namecoin-core; make; make install
 i#namecoind -testnet -walletnotify=/home/doihcain/data/.namecoin/normalise-difficulty.sh &
fi