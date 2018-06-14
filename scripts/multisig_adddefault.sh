#!/bin/bash
#
# Nico Krause (nico@le-space.de)
#
# create a standard multisig transaction with sendtoaddress operation on regtest
#
# cheat sheet https://pastebin.com/nw2Tqg3U
#
# Programming Bitcoin Transaction Scripts
# https://docs.google.com/document/d/1D_gi_7Sf9sOyAHG25cMpOO4xtLq3iJUtjRwcZXFLv1E/edit
# http://www.michaelnielsen.org/ddi/how-the-bitcoin-protocol-actually-works/
#
#make test_regtest_rm
#make test_regtest
myip=localhost
myrpcusername=admin
myrpcpassword=generated-password
type=-regtest
amount=0.02000000
transferAmount=0.00500000

EMAIL_RECIPIENT_ADDR=$(sudo docker exec regtest-alice doichain-cli -regtest getnewaddress)
ALICE_ADDR=$(sudo docker exec regtest-alice doichain-cli -regtest getnewaddress)
BOB_ADDR=$(sudo docker exec regtest-bob	 doichain-cli -regtest getnewaddress)
echo "alice-addr: "$ALICE_ADDR 
echo "bob-addr: "$BOB_ADDR

ALICE_PUBKEY=$(docker exec regtest-alice doichain-cli -regtest validateaddress $ALICE_ADDR |jq '.pubkey')
BOB_PUBKEY=$(docker exec regtest-bob doichain-cli -regtest validateaddress $BOB_ADDR |jq '.pubkey')

echo "alice-pubkey: "$ALICE_PUBKEY 
echo "bob-pubkey: "$BOB_PUBKEY

#MULTISIG_ADDR=$(docker exec regtest-alice doichain-cli -regtest addmultisigaddress 2 '['$ALICE_PUBKEY','$BOB_PUBKEY']')
#MULTISIG_ADDR2=$(docker exec regtest-bob doichain-cli -regtest addmultisigaddress 2 '['$ALICE_PUBKEY','$BOB_PUBKEY']')
MULTISIG_VAL=$(docker exec regtest-alice doichain-cli -regtest createmultisig 2 [$ALICE_PUBKEY,$BOB_PUBKEY])
echo  $MULTISIG_VAL
MULTISIG_ADDR=$(echo $MULTISIG_VAL | jq '.address' | tr -d \")
MULTISIG_REEDEEM=$(echo $MULTISIG_VAL | jq '.redeemScript')
echo "multisig-addr: "$MULTISIG_ADDR
echo "multisig-reedeem: "$MULTISIG_REEDEEM


echo "sending "$amount" to multisig address:"$MULTISIG_ADDR
unixtime=$(date +%s%N)
txid=$(docker exec regtest-alice doichain-cli -regtest sendtoaddress $MULTISIG_ADDR $amount "multisig test" "bob")
echo "txid: "$txid   

#generated=$(docker exec regtest-alice doichain-cli -regtest generatetoaddress 10 $ALICE_ADDR)
#echo $generated |jq

rawtx=$(docker exec regtest-alice doichain-cli -regtest getrawtransaction $txid 1 | jq '.vout[] | select(.value=='$amount')')
echo "rawtx: "$rawtx   
vout_hex=$(echo $rawtx | jq '.scriptPubKey.hex')  
vout_id=$(echo $rawtx | jq '.n')
echo $vout_hex
echo $vout_id

#generated=$(docker exec regtest-alice doichain-cli -regtest generatetoaddress 10 $ALICE_ADDR)
#echo $generated |jq
#feeInput=$(docker exec regtest-alice doichain-cli -regtest listunspent | jq '.[0]')
#echo "feeInput: "$feeInput
#feeInputTxid=$(echo $feeInput | jq '.txid')
#feeInputVout=$(echo $feeInput | jq '.vout')
#feeInputAmount=$(echo $feeInput | jq '.amount')
changeAddr=$(sudo docker exec regtest-alice doichain-cli -regtest getnewaddress) #address where to send change (my own)
#changeAmount=$(echo "$feeInputAmount - $nameAmount" | bc)
#fee=0.005
#changeAmount=$(python3<<<"print($feeInputAmount-$transferAmount-$fee)")
#echo "feeInputAmount: "$feeInputAmount
#echo "nameAmount: "$nameAmount
#echo "changeAmount: "$changeAmount

inputs='[{"txid":"'$txid'","vout":'$vout_id'}]' #, , '$feeInput''$feeInputAmount'
echo "inputs: "$inputs
#outputs='{"'$changeAddr'":'$changeAmount'}'
#, "'$EMAIL_RECIPIENT_ADDR'": '$transferAmount'
outputs='{"'$changeAddr'":'$transferAmount'}'

#outputs_with_name='['$outputs', {"'$EMAIL_RECIPIENT_ADDR'":'$nameAmount'}]' #we should use this later?! see: https://github.com/namecoin/namecoin-core/pull/185
echo "outputs: "$outputs
#'{"'$changeAddr'": 0'$changeAmount', "'$BOB_ADDR'": '$nameAmount'}'
#'[{"txid":"'$txid'","vout":'$vout_id'}]'
#'['$outputs', {"'$EMAIL_RECIPIENT_ADDR'":'$nameAmount'}]'
#txRaw=$(curl --user $myrpcusername:$myrpcpassword --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "createrawtransaction", "params": [$inputs, $outputs] }' -H 'content-type: text/plain;' http://$myip:18339/)
txRaw=$(docker exec regtest-alice doichain-cli -regtest createrawtransaction $inputs $outputs )
echo $txRaw

docker exec regtest-alice doichain-cli -regtest decoderawtransaction $txRaw

privKeyAlice=$(docker exec regtest-alice doichain-cli -regtest dumpprivkey $ALICE_ADDR)
echo "privKeyAlice: "$privKeyAlice
privKeyBob=$(docker exec regtest-bob doichain-cli -regtest dumpprivkey $BOB_ADDR)
echo "privKeyBob: "$privKeyBob

part2='[{"txid":"'$txid'","vout":'$vout_id',"scriptPubKey":'$vout_hex',"redeemScript":'$MULTISIG_REEDEEM'}]'
echo $part2

#BITCOIN_TOOL="docker exec regtest-bob /home/doichain/scripts/bitcoin-tool/bitcoin-tool"
#privKeyAliceWif=$($BITCOIN_TOOL \
#        --input-type private-key-wif \
#        --input-format base58check \
#        --output-type private-key \
#        --output-format base58check \
#        --network namecoin \
#        --input "${privKeyAlice}")

#echo "privKeyAliceWif:"$privKeyAliceWif

hex=$(docker exec regtest-alice doichain-cli -regtest signrawtransaction $txRaw  $part2 '["'$privKeyAlice'"]' | jq '.hex' | tr -d \")
echo "first sign-hex:"$hex
result=$(docker exec regtest-alice doichain-cli -regtest decoderawtransaction $hex)
echo "decode hex:"$hex

result=$(docker exec regtest-bob doichain-cli -regtest signrawtransaction $hex  $part2 '["'$privKeyBob'"]')
echo "second sign-hex:"$result
hex=$(echo $result | jq '.hex' )  
echo "hex:"$hex 
echo "now sending the transaction"
result=$(docker exec regtest-bob doichain-cli -regtest sendrawtransaction $hex)
echo $result 