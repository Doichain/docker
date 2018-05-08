#!/bin/bash
#
# Nico Krause (nico@le-space.de)
#
# This bash script gets called by the doichain-wallet when a new block arrives.
# As soon the difficulty of a block is higher then 1000 we change 'consensus.nPowTargetTimespan' to 14 * 24 * 60 * 60 
# stop the node and do a make, make install and 
# start the node again with parameter -walletnotify=/home/doichain/data/.namecoin/normalise-difficulty.sh

set -e
diff=$(namecoin-cli getblockchaininfo |jq '.difficulty' | sed 'y/e/E/')
echo $diff
goal=1000
diffHighEnough=$(echo $diff'>'$goal | bc -l)
echo $diffHighEnough
if ((1 == 1)); then
 echo "changing nPowTargetTimeSpan" 
 sudo sed -i.bak -e "s/consensus.nPowTargetTimespan[[:space:]]=[[:space:]]0.5/consensus.nPowTargetTimespan = 15 * 24 * 60 * 60/g" /home/doichain/namecoin-core/src/chainparams.cpp
 namecoin-cli stop
 cd /home/doichain/namecoin-core; sudo make; sudo make install
 namecoind -testnet -walletnotify=/home/doihcain/data/.namecoin/normalise-difficulty.sh &
fi