#!/bin/bash
#
# Nico Krause (nico@le-space.de)
#
# create a namecoin multisig transaction with name_doi operation on regtest
#
# cheat sheet https://pastebin.com/nw2Tqg3U
#
# Programming Bitcoin Transaction Scripts
# https://docs.google.com/document/d/1D_gi_7Sf9sOyAHG25cMpOO4xtLq3iJUtjRwcZXFLv1E/edit
# http://www.michaelnielsen.org/ddi/how-the-bitcoin-protocol-actually-works/



#make test_regtest_rm
#make test_regtest
myip=localhost
myrpcusername=admin
myrpcpassword=generated-password
type=-regtest

EMAIL_RECIPIENT_ADDR=$(sudo docker exec regtest-alice namecoin-cli -regtest getnewaddress)
ALICE_ADDR=$(sudo docker exec regtest-alice namecoin-cli -regtest getnewaddress)
BOB_ADDR=$(sudo docker exec regtest-bob	 namecoin-cli -regtest getnewaddress)
echo "alice-addr: "$ALICE_ADDR 
echo "bob-addr: "$BOB_ADDR

ALICE_PUBKEY=$(docker exec regtest-alice namecoin-cli -regtest validateaddress $ALICE_ADDR |jq '.pubkey')
BOB_PUBKEY=$(docker exec regtest-bob namecoin-cli -regtest validateaddress $BOB_ADDR |jq '.pubkey')

echo "alice-pubkey: "$ALICE_PUBKEY 
echo "bob-pubkey: "$BOB_PUBKEY

MULTISIG_VAL=$(docker exec regtest-alice namecoin-cli -regtest createmultisig 2 [$ALICE_PUBKEY,$BOB_PUBKEY])
MULTISIG_VAL2=$(docker exec regtest-bob namecoin-cli -regtest createmultisig 2 [$ALICE_PUBKEY,$BOB_PUBKEY])

MULTISIG_ADDR=$(echo $MULTISIG_VAL | jq '.address' | tr -d \")
MULTISIG_REEDEEM=$(echo $MULTISIG_VAL | jq '.redeemScript')
echo "multisig-addr: "$MULTISIG_ADDR
echo "multisig-reedeem: "$MULTISIG_REEDEEM

MULTISIG_ADDR2=$(echo $MULTISIG_VAL2 | jq '.address' | tr -d \")
MULTISIG_REEDEEM2=$(echo $MULTISIG_VAL2 | jq '.redeemScript')
echo "multisig-addr2: "$MULTISIG_ADDR2
echo "multisig-reedeem2: "$MULTISIG_REEDEEM2

unixtime=$(date +%s%N)
name_address='e/name_'$unixtime
txid=$(docker exec regtest-alice namecoin-cli -regtest name_doi $name_address 'value_date_'$unixtime $MULTISIG_ADDR)
echo "txid: "$txid   

curl -s --user $myrpcusername:$myrpcpassword --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "generatetoaddress", "params": [1,$(ALICE_ADDR)] }' -H 'content-type: text/plain;' http://$myip:18339/ | jq '.result'


##jq info:
## - https://stedolan.github.io/jq/manual/#Basicfilters 
## - https://programminghistorian.org/lessons/json-and-jq
## - http://blog.librato.com/posts/jq-json

rawtx=$(docker exec regtest-alice namecoin-cli -regtest getrawtransaction $txid 1 | jq '.vout[] | select(.scriptPubKey.nameOp)')
echo "rawtx: "$rawtx   
vout_hex=$(echo $rawtx | jq '.scriptPubKey.hex')
vout_id=$(echo $rawtx | jq '.n')
echo "hex: "$vout_hex
echo "id: "$vout_id

nameAmount=0.01
feeInput=$(docker exec regtest-alice namecoin-cli -regtest listunspent | jq '.[0]')
echo "feeInput: "$feeInput
feeInputAmount=$(echo $feeInput | jq '.amount')
changeAddr=$(sudo docker exec regtest-alice namecoin-cli -regtest getnewaddress) #address where to send change (my own)
changeAmount=$(echo "$feeInputAmount - $nameAmount" | bc)
echo "feeInputAmount: "$feeInputAmount
echo "nameAmount: "$nameAmount
echo "changeAmount: "$changeAmount


inputs='[{"txid":"'$txid'","vout":'$vout_id'}]' #, '$feeInputAmount'
echo "inputs: "$inputs
outputs='{"'$changeAddr'": '$changeAmount', "'$EMAIL_RECIPIENT_ADDR'": '$nameAmount'}'
outputs_with_name='[outputs, {"'$name_address'": $nameAmount}]' #we should use this later?! see: https://github.com/namecoin/namecoin-core/pull/185
echo "outputs: "$outputs

#txRaw=$(curl --user $myrpcusername:$myrpcpassword --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "createrawtransaction", "params": [$inputs, $outputs] }' -H 'content-type: text/plain;' http://$myip:18339/)
txRaw=$(docker exec regtest-alice namecoin-cli -regtest createrawtransaction '[{"txid":"'$txid'","vout":'$vout_id'}]' '{"'$changeAddr'": 0'$changeAmount', "'$BOB_ADDR'": '$nameAmount'}')
echo "txRaw: "$txRaw

#op='{"op": "name_doi", "name": "'$name_address'", "value": "it worked"}'
#echo "op: "$op
nameInd=$(docker exec regtest-alice namecoin-cli -regtest decoderawtransaction $txRaw | jq '.vout[] | select(.scriptPubKey.addresses[] | test("'$BOB_ADDR'")) | {nameId:.n}' | jq '.nameId')
echo "nameInd: "$nameInd


hex=$(docker exec regtest-alice namecoin-cli -regtest namerawtransaction $txRaw $nameInd '{"op": "name_update", "name": "'$name_address'", "value": "it worked"}' | jq '.hex')
#hex=$(docker exec regtest-alice namecoin-cli -regtest namerawtransaction $txRaw $nameInd '{"op": "name_doi", "name": "'$name_address'", "value": "it worked"}' | jq '.hex')
echo "hex: "$hex
privKeyAlex=$(docker exec regtest-alice namecoin-cli -regtest dumpprivkey $ALICE_ADDR)
echo "privKey: "$privKeyAlex

txdecode=$(docker exec regtest-alice namecoin-cli -regtest decoderawtransaction $txRaw)
echo $txdecode | jq

#i am not sure about vout:0  and I am not sure about txRaw (could be hex too!)
hex=$(docker exec regtest-alice namecoin-cli -regtest signrawtransaction $txRaw '[{"txid":"'$txid'","vout":0,"scriptPubKey":'$vout_hex',"redeemScript":'$MULTISIG_REEDEEM'}]' '["'$privKeyAlex'"]')
echo $hex | jq 
hex=$(echo $hex | jq '.hex') 

privKeyBob=$(docker exec regtest-bob namecoin-cli -regtest dumpprivkey $BOB_ADDR)
hex=$(docker exec regtest-bob namecoin-cli -regtest signrawtransaction $txRaw '[{"txid":"'$txid'","vout":0,"scriptPubKey":'$vout_hex',"redeemScript":'$MULTISIG_REEDEEM'}]' '["'$privKeyBob'"]')
echo $hex | jq 
hex=$(echo $hex | jq '.hex')  