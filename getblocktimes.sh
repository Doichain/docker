#!/bin/bash

LASTBLOCK=$(namecoin-cli getchaintips | jq '.[0].height' | sed 's/\"//g')
echo "lastblock:"$LASTBLOCK
LAST_TIME=0
for ((z=LASTBLOCK-100;z<=LASTBLOCK;z++))
do
 THIS_HASH=$(namecoin-cli getblockhash $z)
 BLOCK_UNIXTIME=$(namecoin-cli getblock $THIS_HASH | jq '.time')
 DURATION_UNIXTIME=$(($BLOCK_UNIXTIME-$LAST_TIME))
 #echo $DURATION_UNIXTIME
 DURATION_TIME=$(date -d @$DURATION_UNIXTIME | cut -c 12-20)

 LAST_TIME=$BLOCK_UNIXTIME

 BLOCK_TIME=$(date -d @$BLOCK_UNIXTIME)
 echo $z" "$THIS_HASH" "$BLOCK_UNIXTIME" "$BLOCK_TIME" :"$DURATION_TIME
done