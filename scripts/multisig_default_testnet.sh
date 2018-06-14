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
#
# Ottmar?: mrif2Ca8beCm8bP8LgevBjku4QvNxytxf8 (1000) 	037d69cc75154ca157269b6af476e1cf639b335b25ebde9e1a2059f15d370a86e9
# Tobias?: mvpxJG4DXu1NSDzmkjqEHZA5h64EJ7H8vY (100) 	02dce28c1173168fb492c2a93811045d41573be590cf0cffaa0710a16adbf5cf07
# Nico?: mqK5Gg8Nq43tPrQDZgXgxAqVNiV5JQCJRN				02ab97a776366ea41bd64c157533bc9dc6e488b3ce5c590cfe108ae35e20e483ce
#privKey: cSMtWSqHeG25Naz7se1g8aBepGpbnKp1jNTjxip1JCx9p6VtZyLa

#
namecoin-cli -regtest createmultisig 2 '["037d69cc75154ca157269b6af476e1cf639b335b25ebde9e1a2059f15d370a86e9","02dce28c1173168fb492c2a93811045d41573be590cf0cffaa0710a16adbf5cf07","02ab97a776366ea41bd64c157533bc9dc6e488b3ce5c590cfe108ae35e20e483ce"]'
{
  "address": "2NA8q79eQsV3UNqG44mra5cmWyYTY7PoQMr",
  "redeemScript": "5221037d69cc75154ca157269b6af476e1cf639b335b25ebde9e1a2059f15d370a86e92102dce28c1173168fb492c2a93811045d41573be590cf0cffaa0710a16adbf5cf072102ab97a776366ea41bd64c157533bc9dc6e488b3ce5c590cfe108ae35e20e483ce53ae"
}

Import Adresse: importaddress "2NA8q79eQsV3UNqG44mra5cmWyYTY7PoQMr" "multisig-testnet-doichain.org"
Check Balance of MultiSig 	getreceivedbyaddress 2NA8q79eQsV3UNqG44mra5cmWyYTY7PoQMr
txid: ce9ac4be74837142b4b2bfecc17150e996ee9cce8b321cfc94ea1e46ffdd807d

getrawtransaction ce9ac4be74837142b4b2bfecc17150e996ee9cce8b321cfc94ea1e46ffdd807d 1
sp: a914b9448abc65fceb925bda13f268a1fc5f19b0d7ed87
vout_id: 0

inputs='[{"txid":"ce9ac4be74837142b4b2bfecc17150e996ee9cce8b321cfc94ea1e46ffdd807d","vout":0}]' #, , '$feeInput''$feeInputAmount'
outputs='{"mvpxJG4DXu1NSDzmkjqEHZA5h64EJ7H8vY":40000}'
echo "outputs: "$outputs
namecoin-cli -regtest createrawtransaction '[{"txid":"ce9ac4be74837142b4b2bfecc17150e996ee9cce8b321cfc94ea1e46ffdd807d","vout":0}]' '{"mvpxJG4DXu1NSDzmkjqEHZA5h64EJ7H8vY":40000}')
txraw: 01000000017d80ddff461eea94fc1c328bce9cee96e95071c1ecbfb2b442718374bec49ace0000000000ffffffff01a05c7d52a30300001976a914a7f16085a1c0976db8d77f80cb2a02e189d67cdf88ac00000000

decoderawtransaction 01000000017d80ddff461eea94fc1c328bce9cee96e95071c1ecbfb2b442718374bec49ace0000000000ffffffff01a05c7d52a30300001976a914a7f16085a1c0976db8d77f80cb2a02e189d67cdf88ac00000000



privKeyAlice=$(docker exec regtest-alice doichain-cli -regtest dumpprivkey $ALICE_ADDR)
echo "privKeyAlice: "$privKeyAlice
part2='[{"txid":"ce9ac4be74837142b4b2bfecc17150e996ee9cce8b321cfc94ea1e46ffdd807d","vout":0,"scriptPubKey":"a914b9448abc65fceb925bda13f268a1fc5f19b0d7ed87","redeemScript":"5221037d69cc75154ca157269b6af476e1cf639b335b25ebde9e1a2059f15d370a86e92102dce28c1173168fb492c2a93811045d41573be590cf0cffaa0710a16adbf5cf072102ab97a776366ea41bd64c157533bc9dc6e488b3ce5c590cfe108ae35e20e483ce53ae"}]'
echo $part2
signrawtransaction 01000000017d80ddff461eea94fc1c328bce9cee96e95071c1ecbfb2b442718374bec49ace0000000000ffffffff01a05c7d52a30300001976a914a7f16085a1c0976db8d77f80cb2a02e189d67cdf88ac00000000  '[{"txid":"ce9ac4be74837142b4b2bfecc17150e996ee9cce8b321cfc94ea1e46ffdd807d","vout":0,"scriptPubKey":"a914b9448abc65fceb925bda13f268a1fc5f19b0d7ed87","redeemScript":"5221037d69cc75154ca157269b6af476e1cf639b335b25ebde9e1a2059f15d370a86e92102dce28c1173168fb492c2a93811045d41573be590cf0cffaa0710a16adbf5cf072102ab97a776366ea41bd64c157533bc9dc6e488b3ce5c590cfe108ae35e20e483ce53ae"}]' '["cSMtWSqHeG25Naz7se1g8aBepGpbnKp1jNTjxip1JCx9p6VtZyLa"]' 
signrawtransaction 01000000017d80ddff461eea94fc1c328bce9cee96e95071c1ecbfb2b442718374bec49ace00000000b40047304402201418376fb0bfdd762602b5dbf102c32a6cdf3b5982b44765d72e4a07a098921802205dd03eda7af42242dba22b1f4825ed3ea7f0128b4f54e6191bf332bfeca2acb9014c695221037d69cc75154ca157269b6af476e1cf639b335b25ebde9e1a2059f15d370a86e92102dce28c1173168fb492c2a93811045d41573be590cf0cffaa0710a16adbf5cf072102ab97a776366ea41bd64c157533bc9dc6e488b3ce5c590cfe108ae35e20e483ce53aeffffffff01a05c7d52a30300001976a914a7f16085a1c0976db8d77f80cb2a02e189d67cdf88ac00000000  '[{"txid":"ce9ac4be74837142b4b2bfecc17150e996ee9cce8b321cfc94ea1e46ffdd807d","vout":0,"scriptPubKey":"a914b9448abc65fceb925bda13f268a1fc5f19b0d7ed87","redeemScript":"5221037d69cc75154ca157269b6af476e1cf639b335b25ebde9e1a2059f15d370a86e92102dce28c1173168fb492c2a93811045d41573be590cf0cffaa0710a16adbf5cf072102ab97a776366ea41bd64c157533bc9dc6e488b3ce5c590cfe108ae35e20e483ce53ae"}]' '["cSMtWSqHeG25Naz7se1g8aBepGpbnKp1jNTjxip1JCx9p6VtZyLa"]' 



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

MULTISIG_VAL=$(docker exec regtest-alice doichain-cli -regtest createmultisig 2 [$ALICE_PUBKEY,$BOB_PUBKEY])
MULTISIG_ADDR=$(echo $MULTISIG_VAL | jq '.address' | tr -d \")
MULTISIG_REEDEEM=$(echo $MULTISIG_VAL | jq '.redeemScript')
echo  $MULTISIG_VAL | jq
echo "multisig-addr: "$MULTISIG_ADDR
echo "multisig-reedeem: "$MULTISIG_REEDEEM


echo "sending "$amount" to multisig address:"$MULTISIG_ADDR
unixtime=$(date +%s%N)
txid=$(docker exec regtest-alice doichain-cli -regtest sendtoaddress $MULTISIG_ADDR $amount "multisig test" "bob")
echo "txid: "$txid   

rawtx=$(docker exec regtest-alice doichain-cli -regtest getrawtransaction $txid 1 | jq '.vout[] | select(.value=='$amount')')
echo "rawtx: "$rawtx   
vout_hex=$(echo $rawtx | jq '.scriptPubKey.hex')  
vout_id=$(echo $rawtx | jq '.n')
echo $vout_hex
echo $vout_id

changeAddr=$(sudo docker exec regtest-alice doichain-cli -regtest getnewaddress) #address where to send change (my own)

inputs='[{"txid":"'$txid'","vout":'$vout_id'}]' #, , '$feeInput''$feeInputAmount'
echo "inputs: "$inputs
outputs='{"'$changeAddr'":'$transferAmount'}'
echo "outputs: "$outputs
txRaw=$(docker exec regtest-alice doichain-cli -regtest createrawtransaction $inputs $outputs )
echo $txRaw

docker exec regtest-alice doichain-cli -regtest decoderawtransaction $txRaw

privKeyAlice=$(docker exec regtest-alice doichain-cli -regtest dumpprivkey $ALICE_ADDR)
echo "privKeyAlice: "$privKeyAlice
part2='[{"txid":"'$txid'","vout":'$vout_id',"scriptPubKey":'$vout_hex',"redeemScript":'$MULTISIG_REEDEEM'}]'
echo $part2
hex=$(docker exec regtest-alice doichain-cli -regtest signrawtransaction $txRaw  $part2 '["'$privKeyAlice'"]' | jq '.hex' | tr -d \")


echo "first sign-hex:"$hex
result=$(docker exec regtest-alice doichain-cli -regtest decoderawtransaction $hex)
echo "decode hex:"$hex

result=$(docker exec regtest-bob doichain-cli -regtest signrawtransaction $hex  $part2 '["'$privKeyBob'"]')
echo "second sign-hex:"$result
hex=$(echo $result | jq '.hex' )  
echo "hex:"$hex 
echo "now sending the transaction"
result=$(docker exec regtest-bob doichain-cli -regtest sendrawtransaction $sign-hex)
echo $result 