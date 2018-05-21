#!/bin/bash
#
# Nico Krause (nico@le-space.de)
#
# create a standard multisig transaction with sendtoaddress operaton on regtest
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
amount=0.02000000
transferAmount=0.01000000

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

MULTISIG_ADDR=$(echo $MULTISIG_VAL | jq '.address' | tr -d \")
MULTISIG_REEDEEM=$(echo $MULTISIG_VAL | jq '.redeemScript')
echo "multisig-addr: "$MULTISIG_ADDR
echo "multisig-reedeem: "$MULTISIG_REEDEEM

unixtime=$(date +%s%N)
txid=$(docker exec regtest-alice namecoin-cli -regtest sendtoaddress $MULTISIG_ADDR $amount "multisig test" "bob")
echo "txid: "$txid   

miningResult=$(docker exec regtest-alice namecoin-cli -regtest generatetoaddress 10 $MULTISIG_ADDR)
echo $miningResult |jq

#echo curl -s --user $myrpcusername:$myrpcpassword --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "generatetoaddress", "params": [10,$(ALICE_ADDR)] }' -H 'content-type: text/plain;' http://$myip:18339/ | jq '.result'

##jq info:
## - https://stedolan.github.io/jq/manual/#Basicfilters 
## - https://programminghistorian.org/lessons/json-and-jq
## - http://blog.librato.com/posts/jq-json

rawtx=$(docker exec regtest-alice namecoin-cli -regtest getrawtransaction $txid 1 | jq '.vout[] | select(.value=='$amount')')
echo "rawtx: "
echo $rawtx  | jq 
vout_hex=$(echo $rawtx | jq '.scriptPubKey.hex')
vout_id=$(echo $rawtx | jq '.n')
echo "sp: "$vout_hex
echo "vout_id: "$vout_id

feeInput=$(docker exec regtest-alice namecoin-cli -regtest listunspent | jq '.[0]')
echo "feeInput:"
echo $feeInput | jq

feeInputAmount=$(echo $feeInput | jq '.amount')
echo "feeInputAmount: "$feeInputAmount

changeAddr=$(sudo docker exec regtest-alice namecoin-cli -regtest getnewaddress) #address where to send change (my own)
changeAmount=$(echo "$feeInputAmount - $amount" | bc)
#, "'$changeAddr'": '$changeAmount'
txRaw=$(docker exec regtest-alice namecoin-cli -regtest createrawtransaction '[{"txid":"'$txid'","vout":'$vout_id'}]' '{"'$EMAIL_RECIPIENT_ADDR'": '$transferAmount'}') 
echo "txRaw: "$txRaw
txDecode=$(docker exec regtest-alice namecoin-cli -regtest decoderawtransaction $txRaw)
echo $txDecode | jq

privKeyAlex=$(docker exec regtest-alice namecoin-cli -regtest dumpprivkey $ALICE_ADDR)
echo "privKeyAlex: "$privKeyAlex

hex=$(docker exec regtest-alice namecoin-cli -regtest signrawtransaction $txRaw '[{"txid":"'$txid'","vout":'$vout_id',"scriptPubKey":'$vout_hex',"redeemScript":'$MULTISIG_REEDEEM'}]' '["'$privKeyAlex'"]')
echo $hex | jq 
hex=$(echo $hex | jq '.hex') 
exit;
privKeyBob=$(docker exec regtest-bob namecoin-cli -regtest dumpprivkey $BOB_ADDR)
hex=$(docker exec regtest-bob namecoin-cli -regtest signrawtransaction $txRaw '[{"txid":"'$txid'","vout":'$vout_id',"scriptPubKey":'$vout_hex',"redeemScript":'$MULTISIG_REEDEEM'}]' '["'$privKeyBob'"]')
echo $hex | jq 
hex=$(echo $hex | jq '.hex') 
result=$(docker exec regtest-bob namecoin-cli -regtest sendrawtransaction $hex)
echo $result | jq