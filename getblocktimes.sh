#!/bin/bash
#
# Nico Krause (nico@le-space.de)
# This bash script prints out the difficulty and its block times of the last 50 blocks
#
LASTBLOCK=$(doichain-cli getchaintips | jq '.[0].height' | sed 's/\"//g')
echo "lastblock:"$LASTBLOCK
LAST_TIME=0
for ((z=LASTBLOCK-50;z<=LASTBLOCK;z++))
do
 THIS_HASH=$(doichain-cli getblockhash $z)
 THIS_BLOCK=$(doichain-cli getblock $THIS_HASH)
 BLOCK_UNIXTIME=$(echo $THIS_BLOCK | jq '.time')
 #BLOCK_UNIXTIME=$(doichain-cli getblock $THIS_HASH | jq '.time')
 DURATION_UNIXTIME=$(($BLOCK_UNIXTIME-$LAST_TIME))
 echo $THIS_HASH
 DURATION_TIME=$(date -d @$DURATION_UNIXTIME | cut -c 12-20)
 DIFFICULTY=$(echo $THIS_BLOCK | jq '.difficulty')
 LAST_TIME=$BLOCK_UNIXTIME

 BLOCK_TIME=$(date -d @$BLOCK_UNIXTIME)
 echo $z" "$THIS_HASH" "$BLOCK_UNIXTIME" "$BLOCK_TIME" :"$DURATION_TIME" : "$DIFFICULTY
done